module RL

#push!(LOAD_PATH, "./environments")
#push!(LOAD_PATH, "./agents")

export
    AbstractEnvironment,
    AbstractAgent,
    EnvList,
    AgentList,
    CreateEnvironment,
    CreateAgent,


abstract type AbstractEnvironment end

abstract type AbstractAgent end

function EnvList() :
    return ["Driver_Game", "Invasion_Game", "Grid_World", "Mountain_Car", "Locusts_Multiple", "Neverending_Color", "FrozenLake-v0", "Acrobot-v1", "Blackjack-v0", "OffSwitchCartpole-v0", "Pendulum-v0"]
end

function AgentList()
    return ["PS-basic", "PS-sparse", "PS-flexible", "PS-generalization"]
end

function CreateEnvironment(env_name, env_config=None )

    #TODO refactors documentation, should consider the docs

    if env_name == "Driver_Game"
        include("./environments/env_driver_game.jl") 
        env = env_driver_game.TaskEnvironment()
    
    elseif env_name == "Invasion_Game"
        include("./environments/env_invasion_game.jl")
        env = env_invasion_game.TaskEnvironment()

        #TODO Inlcude other envs
    end

    return env

end


function CreateAgent(agent_name, agent_config = None)

    #TODO refactor docuentation, consider adding agernt config specifications

    if agent_name == "PS-basic"
    
        include("./agents/ps_agent_basic.jl")
        agent = ps_agent_basic.BasicPSAgent( agent_config[0], agent_config[1], agent_config[2], agent_config[3], agent_config[4], agent_config[5], agent_config[6])

    elseif agent_name == "PS-sparse"
        include("./agents/ps_agent_sparse.jl")
        agent = ps_agent_sparse.BasicPSAgent( agent_config[0], agent_config[1], agent_config[2], agent_config[3], agent_config[4], agent_config[5], agent_config[6])

    elseif agent_name == "PS-flexible"
        include("./agents/ps_agent_flexible")
        agent = ps_agent_flexible.BasicPSAgent( agent_config[0], agent_config[1], agent_config[2], agent_config[3], agent_config[4])

    elseif agent_name == "PS-generalization"
        include("./agents/ps_agent_generalization")
        agent = ps_agent_generalization( agent_config[0], agent_config[1], agent_config[2], agent_config[3], agent_config[4], agent_config[5], agent_config[6], agent_config[7], agent_config[8], agent_config[9], agent_config[10])

    end

    return agent

end

end #MODULE RL
