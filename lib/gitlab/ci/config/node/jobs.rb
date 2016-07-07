module Gitlab
  module Ci
    class Config
      module Node
        ##
        # Entry that represents a set of jobs.
        #
        class Jobs < Entry
          include Validatable

          validations do
            validates :config, type: Hash
            validate :jobs_presence, on: :processed

            def jobs_presence
              unless relevant?
                errors.add(:config, 'should contain at least one visible job')
              end
            end
          end

          def nodes
            @config
          end

          def relevant?
            @nodes.values.any?(&:relevant?)
          end

          private

          def create_node(key, value)
            job_node = key.to_s.start_with?('.') ? Node::HiddenJob : Node::Job

            job_attributes = { key: key,
                               parent: self,
                               description: "#{key} job definition." }

            job_node.new(value, attributes.merge(job_attributes))
          end
        end
      end
    end
  end
end
