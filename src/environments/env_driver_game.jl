#TODO the instantiation variables should not be hardcoded 

module env_driver_game

export TaskEnvironment, reset!, move!

struct type Driver_Grid <: AbstractEnvironment
    num_actions::Int
    num_directions::Int
    num_colors::Int
    num_percepts::Array{Int,2}
    next_state::Array{Int,1}
end

TaskEnvironment() = Driver_Grid( 2, 2, 2, [2,2], rand([0,1],2))

function reset!(state::Invasion_Grid)
    return state.next_state
end

function move!(state::Invasion_Grid, action::Int)
    
    if state.next_state[1] == action
        reward = 1
    else
        reward = 0
    end

    episode_finished = True
    state.next_state = rand([0,1],2)
    return state.next_state, reward, episode_finished

end

end #module env_driver_game
