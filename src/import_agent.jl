module ImportAgent

    using SQLite
    using JSON: parsefile
    using SourceFile: SourceFileEntity
    using DB
    using Entities: SoccerGame, SoccerTeam, SoccerPlayer, SoccerFine, SoccerScore

    export import_all, import_single

    #
    # Import every file in a directory one after another
    #
    function import_all(file_names::Vector{String}, connection::SQLite.DB)
        map(x -> import_single(x, connection), file_names)
    end

    #
    # Import single file into the database
    #
    function import_single(file_name::String, connection::SQLite.DB)

        source = SourceFileEntity(file_name)
        game_entity = SoccerGame(source)
        team_names = [game_entity.team1.name, game_entity.team2.name]

        #
        # Verify if game already exists in the database
        #
        if DB.exists_game(game_entity.id, connection)
            println("IMPORT SINGLE: GAME EXISTS: $(game_entity.id)")
            return false;
        end

        #
        # Verify if team did not have another game same day so far
        #
        for team_id = 1:2
            if DB.exists_team_on_date(team_names[team_id], game_entity.event_date, connection)
                println("IMPORT SINGLE: TEAM EXISTS: $(team_names[team_id]) ($(game_entity.id))")
                return false
            end
        end

        #
        # Create record in database if all checks passed
        #
        DB.create_game(game_entity, connection)

        #
        # Insert players of both teams
        #
        map(x -> DB.create_player(game_entity.id, team_names[1], x, connection), game_entity.team1.players);
        map(x -> DB.create_player(game_entity.id, team_names[2], x, connection), game_entity.team2.players);

        map(x -> DB.create_player_change(game_entity.id, team_names[1], x, connection), game_entity.team1.changes);
        map(x -> DB.create_player_change(game_entity.id, team_names[2], x, connection), game_entity.team2.changes);

        map(x -> DB.create_player_fine(game_entity.id, team_names[1], x, connection), game_entity.team1.fines);
        map(x -> DB.create_player_fine(game_entity.id, team_names[2], x, connection), game_entity.team2.fines);

        map(x -> DB.create_score(game_entity.id, team_names[1], x, connection), game_entity.team1.scores);
        map(x -> DB.create_score(game_entity.id, team_names[2], x, connection), game_entity.team2.scores);

        return true
    end

end
