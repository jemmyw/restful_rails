module Restful
  module Access
    class RuleSet < Array
      def allow(controller, action)
        matching_rules = select{|rule| rule.matches(controller, action)}
        matching_rules.any? && matching_rules.last.type == :allow
      end
    end
  end
end