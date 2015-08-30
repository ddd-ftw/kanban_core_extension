module Kanban
  class StageContainer

    def initialize(stages)
      @container = stages.each_with_object({}) do |stage, c|
        c[stage.phase] = stage
      end
    end

    def add_card(card, position)
      stage = retrieve(position)
      raise WipLimitReached if stage.reach_wip_limit?
      stage.add_card(card, position.state)
    end

    def pull_card(card, before, after)
      retrieve(before).remove_card(card)
      add_card(card, after)
    end

    def position(card)
      stage = @container.values.detect do |stage|
        stage.contain?(card)
      end
      stage.position(card)
    end

    private

      def retrieve(position)
        @container[position.phase]
      end
  end
end