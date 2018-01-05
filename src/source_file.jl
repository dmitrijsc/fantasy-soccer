module SourceFile

    using JSON
    export SourceFileEntity

    #
    # Datatype for source file. It has only one entity that will
    # keep the JSON object
    #
    immutable SourceFileEntity
        source::Dict{String, Any}
    end

    #
    # Default constructor with a source file name accepted as an input paramter
    #
    function SourceFileEntity(file_name::String)
        return SourceFileEntity(JSON.parsefile(file_name))
    end

end
