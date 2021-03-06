module Activity
  class StateNotFound < StandardError; end
  class TransitionAlreadySetted < StandardError; end
  class UnderCurrentWip < StandardError; end
  class CardOnState < StandardError; end

  class PhaseSpecBuilder

    def initialize(project_id, current)
      @project_id = project_id
      @current = current
      @transition_setted = false

      @phase = current.phase
      @wip_limit = current.wip_limit
      @states = current.transition.to_a
    end

    def change_wip_limit(new_wip_limit, board)
      raise UnderCurrentWip if new_wip_limit.under?(board.count_card(@phase))
      @wip_limit = new_wip_limit
    end

    def disable_wip_limit
      @wip_limit = NoWipLimit.new
    end

    def insert_state_before(state, base_state)
      check_state_exist!(base_state)

      @states = @states.flat_map do |s|
        s == base_state ? [state, s] : s
      end
    end

    def insert_state_after(state, base_state)
      check_state_exist!(base_state)

      @states = @states.flat_map do |s|
        s == base_state ? [s, state] : s
      end
    end

    def remove_state(state, board)
      check_state_exist!(state)
      raise CardOnState if board.any_card_on_step?(Step.new(@phase, state))
      @states.reject! {|s| s == state }
    end

    def set_transition(states)
      raise TransitionAlreadySetted if @states.any?
      @states = states

      @transition_setted = true
    end

    def build_phase_spec
      new_phase_spec.tap do |phase_spec|
        if @transition_setted
          EventPublisher.publish(
            :transition_setted,
            TransitionSetted.new(@project_id, phase_spec, @current)
          )
        end
      end
    end

    private

      def build_transition
        return NoTransition.new if @states.empty?
        Transition.new(@states)
      end

      def new_phase_spec
        PhaseSpec.new(@phase, build_transition, @wip_limit)
      end

      def check_state_exist!(state)
        raise StateNotFound unless @states.include?(state)
      end
  end
end
