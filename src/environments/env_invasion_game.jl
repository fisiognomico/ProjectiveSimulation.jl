module env_invasion_game

export TaskEnvironment, reset!, move!

mutable struct Invasion_Grid <: AbstractEnvironment
    num_actions::Int
    num_percepts::Array{Int,1}
    next_state::Int
end

TaskEnvironment(num_actions=2, num_percepts=2, next_state=rand([0,1])) = Invasion_Grid(num_actions, num_percepts, next_state)

function reset!(state::Invasion_Grid)
    return state.next_state
end

function move!(state::Invasion_Grid, action::Int)
    
    if state.next_state == action
        reward = 1
    else
        reward = 0
    end

    episode_finished = True
    state.next_state = rand([0,1])
    return state.next_state, reward, episode_finished

end

end #module Invasion_Grid 
