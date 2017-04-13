# frozen_string_literal: true

require "sinatra/base"
require "pascoale"

class Punct
  def initialize(value)
    @value = value
  end

  def to_s
    @value.to_s
  end

  def word?
    false
  end
end

class Word
  include Pascoale

  def initialize(value)
    @value = value
  end

  def separated
    parts = SyllableSeparator.new(@value.downcase).separated
    parts = tone(parts)
    parts.join("-")
  rescue => e
    raise unless e.message.match?(/^Cannot separate/)
    "#{@value.downcase} <i>(erro!)</i>"
  end

  def tone(parts)
    reflector = Reflector.new(@value.downcase)
    rslt = parts.dup
    if reflector.oxytone?
      rslt[-1] = "<b>#{parts[-1]}</b>"
    elsif reflector.paroxytone?
      rslt[-2] = "<b>#{parts[-2]}</b>"
    elsif reflector.proparoxytone?
      rslt[-3] = "<b>#{parts[-3]}</b>"
    end
    rslt
  end

  def to_s
    return @value.to_s if @value.match?(/\d+/)
    separated.to_s
  end

  def word?
    true
  end
end

class App < Sinatra::Base
  get "/" do
    erb :main
  end

  post "/pasqualize" do
    @text = params[:text]
    @tokens = tokenize(@text).map(&:to_s)
    erb :pasqualized
  end

  def tokenize(text)
    tokens = text.scan(/([[:blank:]]|[[:punct:]])|([[:word:]]+)/)
    tokens.map { |(p, w)| w.nil? ? Punct.new(p) : Word.new(w) }
          .select(&:word?)
  end
end
