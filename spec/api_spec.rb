# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/transaction'

def app
    FiBuy::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/transaction_seeds.yml')

describe 'Test Transaction Web API' do
  include Rack::Test::Methods

  before do
    Dir.glob('app/db/store/*.txt').each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the rot route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle transactions' do
    it 'HAPPY: should be able to get list of all transaction' do
      FiBuy::Transaction.new(DATA[0]).save
      FiBuy::Transaction.new(DATA[1]).save

      get 'api/v1/transactions'
      result = JSON.parse last_response.body
      _(result['transaction_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single transaction' do
      FiBuy::Transaction.new(DATA[1]).save
      id = Dir.glob('app/db/store/*.txt').first.split(%r{[/\.]})[3]

      get "/api/v1/transactions/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown transaction requested' do
      get '/api/v1/transactions/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new transactions' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/transactions', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end