module Gitlab
  module Ci
    class Config
      module Node
        ##
        # Base abstract class for each configuration entry node.
        #
        class Entry
          class InvalidError < StandardError; end

          attr_reader :config, :attributes
          attr_accessor :key, :parent, :global, :description

          def initialize(config, **attributes)
            @config = config
            @nodes = {}

            (@attributes = attributes).each do |attribute, value|
              public_send("#{attribute}=", value)
            end

            @validator = self.class.validator.new(self)
            @validator.validate
          end

          def process!
            compose! unless leaf?
            @validator.validate(:processed) if valid?
          end

          def leaf?
            nodes.none?
          end

          def nodes
            self.class.nodes
          end

          def descendants
            @nodes.values
          end

          def ancestors
            @parent ? @parent.ancestors + [@parent] : []
          end

          def valid?
            errors.none?
          end

          def errors
            @validator.messages + @nodes.values.flat_map(&:errors)
          end

          def value
            if leaf?
              @config
            else
              meaningful = @nodes.select do |_key, value|
                value.defined? && value.relevant?
              end

              Hash[meaningful.map { |key, node| [key, node.value] }]
            end
          end

          def defined?
            true
          end

          def relevant?
            true
          end

          def self.default
          end

          def self.nodes
            {}
          end

          def self.validator
            Validator
          end

          private

          def compose!
            return unless valid?

            nodes.each do |key, essence|
              @nodes[key] = create_node(key, essence)
            end

            @nodes.each_value(&:process!)
          end

          def create_node(key, essence)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
