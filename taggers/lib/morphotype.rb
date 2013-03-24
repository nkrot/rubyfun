
class Morphotype

#Numeric The word is rare and contains at least one numeric characters.
#All Capitals The word is rare and consists entirely of capitalized letters.
#Last Capital The word is rare, not all capitals, and ends with a capital letter.
#Rare The word is rare and does not fit in the other classes.

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
end
