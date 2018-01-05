module Entities

    using SourceFile: SourceFileEntity

    export SoccerGame, SoccerFine, SoccerPlayer, SoccerPlayerChange, SoccerTeam, SoccerScore

    immutable SoccerScore
        time::Int64
        nr::Int64
        score_type::String
        assistants::Vector{Int64}
    end

    immutable SoccerFine
        time::Int64
        nr::Int64
    end

    immutable SoccerPlayerChange
        time::Int64
        nr1::Int64
        nr2::Int64
    end

    immutable SoccerPlayer
        nr::Int64
        name::String
        lastname::String
        role::String
        base_team::Int64
    end

    immutable SoccerTeam
        name::String
        players::Vector{SoccerPlayer}
        changes::Vector{SoccerPlayerChange}
        fines::Vector{SoccerFine}
        scores::Vector{SoccerScore}
    end

    immutable SoccerGame
        id::String
        team1::SoccerTeam
        team2::SoccerTeam
        event_date::Int
        location::String
        judge::String
    end

    function SoccerScore(source::Dict{String, Any})

        time = parse(Int64, replace(source["Laiks"], ":", ""))
        assistance = Vector{Int64}()

        if haskey(source, "P") && source["P"] != ""
            assistance = map(x -> x["Nr"], isa(source["P"], AbstractArray) ? source["P"] : [source["P"]])
        end

        SoccerScore(time, source["Nr"], source["Sitiens"], assistance)
    end

    function SoccerFine(source::Dict{String, Any})
        time = parse(Int64, replace(source["Laiks"], ":", ""))
        SoccerFine(time, source["Nr"])
    end

    function SoccerPlayerChange(source::Dict{String, Any})
        time = parse(Int64, replace(source["Laiks"], ":", ""))
        SoccerPlayerChange(time, source["Nr1"], source["Nr2"])
    end

    function SoccerPlayer(source::Dict{String, Any}, base_players::Vector{Int64})
        SoccerPlayer(source["Nr"], source["Vards"], source["Uzvards"], source["Loma"], 1 * (source["Nr"] in base_players))
    end

    function SoccerTeam(source::Dict{String, Any})

        base_players = map(x -> x["Nr"], source["Pamatsastavs"]["Speletajs"])
        players = map(x -> SoccerPlayer(x, base_players), source["Speletaji"]["Speletajs"])

        changes = Vector{SoccerPlayerChange}()
        fines = Vector{SoccerFine}()
        scores = Vector{SoccerScore}()

        if haskey(source, "Mainas") && source["Mainas"] != "" && haskey(source["Mainas"], "Maina")
            changes = map(x -> SoccerPlayerChange(x), isa(source["Mainas"]["Maina"], AbstractArray) ? source["Mainas"]["Maina"] : [source["Mainas"]["Maina"]])
        end

        if haskey(source, "Sodi") && source["Sodi"] != "" && haskey(source["Sodi"], "Sods")
            fines = map(x -> SoccerFine(x), isa(source["Sodi"]["Sods"], AbstractArray) ? source["Sodi"]["Sods"] : [source["Sodi"]["Sods"]])
        end

        if haskey(source, "Varti") && source["Varti"] != "" && haskey(source["Varti"], "VG")
            scores = map(x -> SoccerScore(x), isa(source["Varti"]["VG"], AbstractArray) ? source["Varti"]["VG"] : [source["Varti"]["VG"]])
        end

        SoccerTeam(source["Nosaukums"], players, changes, fines, scores)

    end

    #
    # Convert Source to multi-nested-class definition
    #
    function SoccerGame(source::SourceFileEntity)

        game_source = source.source["Spele"]

        team_1 = SoccerTeam(game_source["Komanda"][1])
        team_2 = SoccerTeam(game_source["Komanda"][2])
        event_date = Dates.date2epochdays(Date(game_source["Laiks"], "y/m/d"))
        location = game_source["Vieta"]

        judge_name = game_source["VT"]["Vards"]
        judge_lastname = game_source["VT"]["Uzvards"]

        judge = "$judge_name $judge_lastname"
        id = "$event_date-$(team_1.name)-$(team_2.name)"

        SoccerGame(id, team_1, team_2, event_date, location, judge)
    end



end
