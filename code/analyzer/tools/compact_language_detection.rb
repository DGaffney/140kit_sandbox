class CompactLanguageDetection < AnalysisMetadata
  $language_map = {"ENGLISH" => 0, "DANISH" => 1, "DUTCH" => 2, "FINNISH" => 3, "FRENCH" => 4, "GERMAN" => 5, "HEBREW" => 6, "ITALIAN" => 7, "JAPANESE" => 8, "KOREAN" => 9, "NORWEGIAN" => 10, "POLISH" => 11, "PORTUGUESE" => 12, "RUSSIAN" => 13, "SPANISH" => 14, "SWEDISH" => 15, "CHINESE" => 16, "CZECH" => 17, "GREEK" => 18, "ICELANDIC" => 19, "LATVIAN" => 20, "LITHUANIAN" => 21, "ROMANIAN" => 22, "HUNGARIAN" => 23, "ESTONIAN" => 24, "TG_UNKNOWN_LANGUAGE" => 25, "UNKNOWN_LANGUAGE" => 26, "BULGARIAN" => 27, "CROATIAN" => 28, "SERBIAN" => 29, "IRISH" => 30, "GALICIAN" => 31, "TAGALOG" => 32, "TURKISH" => 33, "UKRAINIAN" => 34, "HINDI" => 35, "MACEDONIAN" => 36, "BENGALI" => 37, "INDONESIAN" => 38, "LATIN" => 39, "MALAY" => 40, "MALAYALAM" => 41, "WELSH" => 42, "NEPALI" => 43, "TELUGU" => 44, "ALBANIAN" => 45, "TAMIL" => 46, "BELARUSIAN" => 47, "JAVANESE" => 48, "OCCITAN" => 49, "URDU" => 50, "BIHARI" => 51, "GUJARATI" => 52, "THAI" => 53, "ARABIC" => 54, "CATALAN" => 55, "ESPERANTO" => 56, "BASQUE" => 57, "INTERLINGUA" => 58, "KANNADA" => 59, "PUNJABI" => 60, "SCOTS_GAELIC" => 61, "SWAHILI" => 62, "SLOVENIAN" => 63, "MARATHI" => 64, "MALTESE" => 65, "VIETNAMESE" => 66, "FRISIAN" => 67, "SLOVAK" => 68, "CHINESE_T" => 69, "FAROESE" => 70, "SUNDANESE" => 71, "UZBEK" => 72, "AMHARIC" => 73, "AZERBAIJANI" => 74, "GEORGIAN" => 75, "TIGRINYA" => 76, "PERSIAN" => 77, "BOSNIAN" => 78, "SINHALESE" => 79, "NORWEGIAN_N" => 80, "PORTUGUESE_P" => 81, "PORTUGUESE_B" => 82, "XHOSA" => 83, "ZULU" => 84, "GUARANI" => 85, "SESOTHO" => 86, "TURKMEN" => 87, "KYRGYZ" => 88, "BRETON" => 89, "TWI" => 90, "YIDDISH" => 91, "SERBO_CROATIAN" => 92, "SOMALI" => 93, "UIGHUR" => 94, "KURDISH" => 95, "MONGOLIAN" => 96, "ARMENIAN" => 97, "LAOTHIAN" => 98, "SINDHI" => 99, "RHAETO_ROMANCE" => 100, "AFRIKAANS" => 101, "LUXEMBOURGISH" => 102, "BURMESE" => 103, "KHMER" => 104, "TIBETAN" => 105, "DHIVEHI" => 106, "CHEROKEE" => 107, "SYRIAC" => 108, "LIMBU" => 109, "ORIYA" => 110, "ASSAMESE" => 111, "CORSICAN" => 112, "INTERLINGUE" => 113, "KAZAKH" => 114, "LINGALA" => 115, "MOLDAVIAN" => 116, "PASHTO" => 117, "QUECHUA" => 118, "SHONA" => 119, "TAJIK" => 120, "TATAR" => 121, "TONGA" => 122, "YORUBA" => 123, "CREOLES_AND_PIDGINS_ENGLISH_BASED" => 124, "CREOLES_AND_PIDGINS_FRENCH_BASED" => 125, "CREOLES_AND_PIDGINS_PORTUGUESE_BASED" => 126, "CREOLES_AND_PIDGINS_OTHER" => 127, "MAORI" => 128, "WOLOF" => 129, "ABKHAZIAN" => 130, "AFAR" => 131, "AYMARA" => 132, "BASHKIR" => 133, "BISLAMA" => 134, "DZONGKHA" => 135, "FIJIAN" => 136, "GREENLANDIC" => 137, "HAUSA" => 138, "HAITIAN_CREOLE" => 139, "INUPIAK" => 140, "INUKTITUT" => 141, "KASHMIRI" => 142, "KINYARWANDA" => 143, "MALAGASY" => 144, "NAURU" => 145, "OROMO" => 146, "RUNDI" => 147, "SAMOAN" => 148, "SANGO" => 149, "SANSKRIT" => 150, "SISWANT" => 151, "TSONGA" => 152, "TSWANA" => 153, "VOLAPUK" => 154, "ZHUANG" => 155, "KHASI" => 156, "SCOTS" => 157, "GANDA" => 158, "MANX" => 159, "MONTENEGRIN" => 160, "NUM_LANGUAGES" => 161}
  def self.run(analysis_metadata_id)
    @analysis_metadata = AnalysisMetadata.first(:id => analysis_metadata_id)
    curation = @analysis_metadata.curation
    conditional = Analysis.curation_conditional(curation)
    graph = Graph.first_or_create(:title => "cld_value_overview", :style => "table", :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id)
    offset = 0
    limit = 20000
    tweets = Tweet.all({:limit => limit, :offset => offset, :fields => [:twitter_id, :text]}.merge(conditional))
    language_set = {}
    while !tweets.empty?
      tweets.each do |tweet|
        language = self.detect_language_name(tweet.text)
        if language_set[language].nil?
          language_set[language] = 1
        else
          language_set[language] += 1
        end
      end
      offset += limit
      tweets = Tweet.all({:limit => limit, :offset => offset, :fields => [:twitter_id, :text]}.merge(conditional))
    end
    values = []
    language_set.each_pair do |language, count|
      values << {:graph_id => graph.id, :label => language, :value => count, :analysis_metadata_id => @analysis_metadata.id, :curation_id => curation.id}
    end
    GraphPoint.save_all(values)
    return true
  end
  
  def self.detect_language_name(data)
    value = CLD.detect_language(data)[:name]
    value = "unknown" if value == "TG_UNKNOWN_LANGUAGE"
    return value.split("_").collect(&:capitalize).join(" ")
  end
end

