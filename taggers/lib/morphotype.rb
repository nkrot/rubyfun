
class Morphotype

  # Numeric The word is rare and contains at least one numeric characters.
  # All Capitals The word is rare and consists entirely of capitalized letters.
  # Last Capital The word is rare, not all capitals, and ends with a capital letter.
  # Rare The word is rare and does not fit in the other classes.

  def initialize(klass=:single)
    set_classifier(klass)
  end

  # valid values:
  #  :single, :multi
  def use_type_of_rare=(klass)
    set_classifier(klass)
  end

  # universal interface
  def type_of_rare(word)
    @classifier.call(word)
  end

  ####################################################################
  # low levels

  def type_of(word)
    case word
    when /\d/
      "_NUMERIC_"
    when /^[[:upper:]]+$/
      "_ALLCAPS_"
    when /[[:upper:]]$/
      "_LASTCAP_"
    end
  end

  def rare
    "_RARE_"
  end

  ####################################################################
  private
  ####################################################################

  def set_classifier(klass)
    case klass
    when :single
      @classifier = lambda {|word| rare}
    when :multi
      @classifier = lambda {|word| type_of(word) || rare }
    else
      raise "Unknown type of rare requested: #{klass}"
    end
  end
end
