module BasicAgent

export 
    BasicPSAgent, 
    percept_process,

mutable struct BasicPSAgent <: AbstractAgent
```
A basic PSAgent is defined by
 - num_actions: Int>=1
 - num_percepts_list : list of integers >= 1 , repr. cardinality of each feature of percept space
 - gamma_damping : float between [0,1], damping of h-values
 - eta_glow_damping : float between [0,1], damping of glow, eta=1 switches off glow
 - policy_type : string, standard or softmax to compute the probability of h-values
 - beta_softmax : float >= 0, probabilities are proportional to exp(beta*h_value)
 - num_reflections : integer >= 0, setting how many times the agent reflects, ie potentially goes back to the percept
 - num_percepts : total number of possible percepts
 - h_matrix : Matrix of probabilities, necessary for both policies
 - g_matrix : glow matrix, for processing delayed rewards
 - last_percept_action : depends on the environment, for 
 - e_matrix : matrix of "emoticons" as presented in the paper, represented by a mtrix of bool, 
            true-false represent a good-bad interaction with the environment
 
```

    num_actions::Int
    num_percepts_list::Array{Int,1}
    gamma_damping::Float64
    eta_glow_damping::Float64
    policy_type::String
    beta_softmax::Float64
    num_reflections::Int
    num_percepts::Int
    h_matrix::Array{Float64, 2}
    g_matrix::Array{Float64, 2}
    last_percept_action::Array{Int,2}
    e_matrix::Array{Bool, 2}
    function BasicPSAgent(num_actions, num_percepts_list, gamma_damping, eta_glow_damping, policy_type, beta_softmax, num_reflections,          last_percept_action=[0,0])
        
        num_percepts = prod(num_percepts_list)
        h_matrix = ones(num_actions, num_percepts)
        g_matrix = zeros(num_actions, num_percepts)

        if num_reflections > 0
            e_matrix = ones(Bool, num_actions, num_percepts)
        else
            e_matrix = zeros(Bool, num_actions, num_percepts)
        end

        return new(num_actions, num_percepts_list, gamma_damping, eta_glow_damping, policy_type, beta_softmax, num_reflections,                     last_percept_action, num_percepts, h_matrix, g_matrix, e_matrix)

    end
end

function percept_process(agent::BasicPSAgent, observation::Array{Int, 1})
    ```
    Takes a multi-feature percept and reduces it to a single index integer.
    Input a list of integers>=0, same length as self.num_percepts_list;
    observation[i] <= num_percepts_list[i] in order to respect percept cardinality
    Output : Integer

    ```
    percept = 0
    for feat in 1:length(observation)
        percept += (observation[feat] * prod(agent.num_percepts_list[1:feat]))
    end


    return percept
end

function deliberate_and_learn!(agent::BasicPSAgent, observation::Array{Int, 1}, reward::Float64)
    ```
    Gives an observation and a reward, this function update the h_matrix, chooses the next action 
    and records the choice in the g_matrix and last_percept_action
    Output : action , integer index

    ```
    #learning is represented by reward, forgetting by damping
    agent.h_matrix = agent.h_matrix - agent.gamma_damping * (agent.h_matrix - 1) + agent.g_matrix * reward
    #reflection update, if reward is negative for last action , we get "sad emoticon"
    if (agent.num_reflections > 0) && (agent.last_percept_action != false) && (reward <= 0)
        agent.e_matrix[agent.last_percept_action[1], agent.last_percept_action[2]] = false
    end
    #sample an action for percept p, according to Distribution in corresponding colvec in h_matrix for percept
    percept = percept_process(agent, observation)
    action_weights = probability_distr(agent, percept)
    action = sample(1:agent.num_actions, Weights(action_weights))
    # If actions return a negative reward, retry up to N reflections
    if agent.num_reflections > 0
        for idx in 1:agent.num_reflections
            if agent.e_matrix[action, percept]
                break
            end
            action = sample(1:agent.num_actions, Weights(action_weights))
        end
    end
    #glowing : delay rewards, set current clip to 1 (max)
    agent.g_matrix = (1 - agent.eta_glow_damping) * agent.g_matrix
    agent.g_matrix[action, percept] = 1
    #update new last_percept
    if agent.num_reflections > 0
        agent.last_percept_action = [action, percept]
    end
    #ret Int
    return action
end

function probability_distr(agent::BasicPSAgent, percept::Int)
    ```
    Given a percept index, this fn returns a probability distribution over actions
    (an arr of lentgh num_actions normalized) computed according to policy
    ```

    if agent.policy_type == "standard"
        h_vector = agent.h_matrix[:, percept]
        probability_distr = h_vector / sum(h_vector)
    elseif agent.policy_type == "softmax":
        h_vector = agent.beta_softmax * agent.h_matrix[:, percept]
        h_vector_mod = h_vector - maximum(h_vector)
        probability_distr = exp.(h_vector_mod) / sum(exp.(h_vector_mod))
    else
        error("Defined distribution not found")
    end

    return probability_distr

end
end # module BasicAgent
