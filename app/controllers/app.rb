# frozen_string_literal: true
#12345-9
require 'roda'
require 'json'

require_relative '../models/transaction'

module FiBuy
  # Web controller for Fibuy API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Transaction.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'FibuyAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'transactions' do
            # GET api/v1/transactions/[id]
            routing.get String do |id|
                Transaction.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Transaction not found' }.to_json
            end

            # GET api/v1/transactions
            routing.get do
              output = { transaction_ids: Transaction.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/transactions
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_tran = Transaction.new(new_data)

              if new_tran.save
                response.status = 201
                { message: 'Transaction saved', id: new_tran.id }.to_json
              else
                routing.halt 400, { message: 'Could not save transaction' }.to_json
              end
            end
          end
        end
      end
    end
  end
end