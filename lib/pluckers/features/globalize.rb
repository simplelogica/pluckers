module Pluckers
  ##
  # This module groups diferent modules that will configure and build the
  # results for a specific kind of information (attributes, translations,
  # relations...)
  #
  # All this modules will have two methods, one for configuration (e.g, attributes
  # to be included in the real pluck) and one for building the final results
  module Features

    ##
    # This module implements plucking belongs_to relationships in a recursive
    # way.
    #
    # The options used in this feature are:
    #
    #  * attributes: Names of attributes of the objects to be plucked. This
    #    attributes should be the names of the translated attributes by Globalize.
    #
    #  * attributes_with_locale: A hash when the key is a locale and the value
    #    is an array of attributes to pluck. As a result we will have a series of
    #    attributes with the name following the syntax attreibute_locale. E.g: The
    #    option could be { es: [:name], en: [:name, :location]} and we would obtain
    #    :name_es, :name_en and :location_en keys in the hash result

    module Globalize


      ##
      # Here we obtain the renames enabled for this plucker
      def configure_query
        super

        return if @klass_reflections[:translations].nil?

        if @options[:attributes]

          plucker_attributes = @options[:attributes].map(&:to_sym)

          klass_translated_attributes = @records.try(:translated_attribute_names) || []

          klass_translated_attributes = klass_translated_attributes.map(&:to_sym)

          @translated_attributes = plucker_attributes & klass_translated_attributes

          @options[:attributes] = plucker_attributes - klass_translated_attributes

        end

        @translated_attributes ||= []
        @attributes_with_locale = @options[:attributes_with_locale] || {}

        unless @translated_attributes.blank? && @attributes_with_locale.blank?

          # We obtain the info about the translations relation
          translation_table_name = @records.klass::Translation.table_name
          translation_foreign_key = @klass_reflections[:translations].foreign_key

          # And we perform a join for each locale
          fallbacks = ::Globalize.fallbacks(::Globalize.locale)

          fallbacks.each do |locale|
            @records = @records.joins(
              "LEFT OUTER JOIN #{translation_table_name} AS locale_#{locale}_translation ON (
                #{@records.klass.table_name}.id = locale_#{locale}_translation.#{translation_foreign_key} AND
                locale_#{locale}_translation.locale = '#{locale}'
              )")

          end

          # The attribute to pluck must get the first non nil field
          @attributes_to_pluck += @translated_attributes.map do |field|
            {
              name: field,
              sql: "COALESCE(NULL, #{
                fallbacks.map{|locale| "locale_#{locale}_translation.#{field}" }.join(',')
                })"
            }
          end

          # For the attributes with locale (name_es, name_en...)
          @attributes_with_locale.each do |locale, attributes|

            # We add the locales that are not fallback
            unless fallbacks.include? locale
              @records = @records.joins(
                "LEFT OUTER JOIN #{translation_table_name} AS locale_#{locale}_translation ON (
                  #{@records.klass.table_name}.id = locale_#{locale}_translation.#{translation_foreign_key} AND
                  locale_#{locale}_translation.locale = '#{locale}'
                )")
            end

            # And we add the attribute to be plucked
            @attributes_to_pluck += attributes.map do |field|
              {
                name: "#{field}_#{locale}".to_sym,
                sql: "locale_#{locale}_translation.#{field}"
              }
            end
          end
        end
      end

    end
  end
end
