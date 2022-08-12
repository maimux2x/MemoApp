# frozen_string_literal: true

require 'pg'
require 'yaml'

# DBとの接続情報を管理
class MemosDataConnection
  def self.connect
    dbconf = YAML.load_file('config/database.yml')['db']['development']
    @connect ||= PG.connect(dbconf)
  end
end
