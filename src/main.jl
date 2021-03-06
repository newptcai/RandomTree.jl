"Entry point of command line script"
function main()
    parsed_args = parse_commandline()

    seed = parsed_args["seed"]
    if  seed != nothing
        Random.seed!(seed)
    end

    if parsed_args["log_size"] != nothing
        size = 10^parsed_args["log_size"]
    else
        size = parsed_args["size"]
    end

    tree_type = TREE_DICT[parsed_args["tree_type"]]
    tree_ins = missing
    if tree_type == DAryTree
        tree_ins = DAryTree(size, parsed_args["d"])
    elseif tree_type == FullDAryTree
        tree_ins = FullDAryTree(parsed_args["tall"], parsed_args["d"])
    else
        tree_ins = tree_type(size)
    end

    sim = missing
    if parsed_args["%COMMAND%"] == "kcut"
        sim = KcutSimulator(tree_ins, parsed_args["kcut"]["k"])
    elseif parsed_args["%COMMAND%"] == "log-prod"
        sim = LogProductSimulator(tree_ins, parsed_args["log-prod"]["pow"])
    elseif parsed_args["%COMMAND%"] == "size-power"
        sim = SizePowerSimulator(tree_ins, parsed_args["size-power"]["pow"])
    elseif parsed_args["%COMMAND%"] == "height"
        sim = HeightSimulator(tree_ins)
    elseif parsed_args["%COMMAND%"] == "total-path"
        sim = TotalPathSimulator(tree_ins)
    elseif parsed_args["%COMMAND%"] == "leaf"
        sim = LeafSimulator(tree_ins)
    end

    if !ismissing(sim)
        print_simulation(sim, parsed_args["num"])
    end
end
