module InputSource

    const DATA_DIR = "data"
    const DATA_FORMAT = ".json"

    export read_data_dir

    #
    # Read all DATA_FORMAT files from DATA_DIR
    # Returns: list of all full file path following the requirements
    #
    function read_data_dir()
        joinpath.(DATA_DIR, filter(x -> endswith(x, DATA_FORMAT), readdir(DATA_DIR)))
    end

end
