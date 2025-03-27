# frozen_string_literal: true

require 'spec_helper'

describe Config do
  describe '.token_secret' do
    it 'devuelve nil si no hay variable de entorno' do
      expect(Config.token_secret).to be_nil
    end

    it 'lee la variable de entorno si existe' do
      stub_env('TOKEN_SECRET', 'custom_secret')
      expect(Config.token_secret).to eq('custom_secret')
    end
  end
end
