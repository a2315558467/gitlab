module Gitlab
  module CycleAnalytics
    class StagingStage < BaseStage
      include ProductionHelper
      def start_time_attrs
        @start_time_attrs ||= mr_metrics_table[:merged_at]
      end

      def end_time_attrs
        @end_time_attrs ||= mr_metrics_table[:first_deployed_to_production_at]
      end

      def name
        :staging
      end

      def title
        s_('CycleAnalyticsStage|Staging')
      end

      def legend
        _("Related Deployed Jobs")
      end

      def description
        _("从合并请求被合并到发布所花费的时间")
      end
    end
  end
end
