require 'json'
require 'base64'
require 'rbnacl'

module FiBuy
    class Transaction
        STORE_DIR = 'app/db/store/'

        def initialize(new_document)
            @id = new_document['id'] || new_id
            @title = new_document['title']
            @description = new_document['description']
            @price = new_document['price']
            @due_date = new_document['due_date']
            @leader = new_document['leader']
            @member = new_document['member']
            @limit_member = new_document['limit_member']
            @commodity_url = new_document['commodity_url']
        end

        attr_reader :id, :title, :description, :price, :due_date, :leader, :member, :limit_member, :commodity_url

        def to_json(options = {})
            JSON(
                {
                    type: 'transaction',
                    id: id,
                    title: title,
                    description: description,
                    price: price,
                    due_date: due_date,
                    leader: leader,
                    member: member,
                    limit_member: limit_member,
                    commodity_url: commodity_url
                },
                options
            )
        end

        # File store must be setup once when application runs
        def self.setup
            Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
        end

        # Stores document in file store
        def save
            File.write(STORE_DIR + id + '.txt', to_json)
        end

        # Query method to find one document
        def self.find(find_id)
            transaction_file = File.read(STORE_DIR + find_id + '.txt')
            Transaction.new JSON.parse(transaction_file)
        end

        def self.all
            Dir.glob(STORE_DIR + '*.txt').map do |file|
                file.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
            end
        end

        private

        def new_id
            timestamp = Time.now.to_f.to_json
            Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
        end
    end
end
            