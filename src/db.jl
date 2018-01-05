module DB

    using SQLite
    using DataFrames: nrow, start, DataFrame
    using Entities: SoccerGame, SoccerPlayer, SoccerPlayerChange, SoccerFine, SoccerScore

    export create_connection, exists_game, exists_team_on_date, create_game, create_player, create_player_change, drop_tables
    export get_stats_game_table, get_stats_players_rating, get_stats_goalkeepers_top, get_stats_players_fines
    export get_stats_team_players, get_stats_team_players_goalkeepers, get_stats_judge_rating, get_stats_duplicated_players

    #
    # Name of the database
    #
    DB_NAME = "soccer_homework.sqlite"

    #
    # Create a new connection to the database
    # and verify if the database has been previously initialized
    #
    function create_connection()

        connection = SQLite.DB(DB_NAME)

        if nrow(SQLite.tables(connection)) == 0
            create_tables(connection)
        end

        connection
    end

    #
    # In case we are starting without tables, we should define our new structure
    #
    function create_tables(connection::SQLite.DB)

        println("DATABASE: CREATING DATABASE TABLES")

        SQLite.query(connection, "CREATE TABLE games (id TEXT, team1 TEXT, team2 TEXT, event_date INT, location TEXT, judge TEXT);")
        SQLite.query(connection, "CREATE TABLE players (game_id TEXT, team_name TEXT, nr INT, name TEXT, lastname TEXT, role TEXT, base_team INT);")
        SQLite.query(connection, "CREATE TABLE changes (game_id TEXT, team_name TEXT, event_time INT, nr1 INT, nr2 INT);")
        SQLite.query(connection, "CREATE TABLE fines (game_id TEXT, team_name TEXT, event_time INT, nr INT);")
        SQLite.query(connection, "CREATE TABLE scores (game_id TEXT, team_name TEXT, event_time INT, nr INT, score_type TEXT);")
        SQLite.query(connection, "CREATE TABLE scores_assists (game_id TEXT, team_name TEXT, event_time INT, nr INT, assist_nr INT);")

    end

    #
    # Drop all tables
    #
    function drop_tables(connection::SQLite.DB)

        for table_name in SQLite.tables(connection)[:name]
            SQLite.drop!(connection, table_name.value)
        end
    end

    #
    # Verify if game has already been created in the database
    #
    function exists_game(id::String, connection::SQLite.DB)
        nrow(SQLite.query(connection, "SELECT id FROM games WHERE id = '$id' LIMIT 1")) > 0
    end

    #
    # Create new game in the database
    #
    function create_game(entity::SoccerGame, connection::SQLite.DB)
        SQLite.query(connection, "INSERT INTO games VALUES ('$(entity.id)', '$(entity.team1.name)', '$(entity.team2.name)', $(entity.event_date), '$(entity.location)', '$(entity.judge)')")
    end

    #
    # Verify if team has a game for a specific date
    #
    function exists_team_on_date(team::String, event_date::Int, connection::SQLite.DB)
        nrow(SQLite.query(connection, "SELECT id FROM games WHERE event_date = $event_date and (team1 = '$team' or team2 = '$team') LIMIT 1")) > 0
    end

    #
    # Create new game in the database
    #
    function create_player(game_id::String, team_name::String, entity::SoccerPlayer, connection::SQLite.DB)
        SQLite.query(connection, "INSERT INTO players VALUES ('$game_id', '$team_name', '$(entity.nr)', '$(entity.name)', '$(entity.lastname)', '$(entity.role)', '$(entity.base_team)')")
    end

    #
    # Create players changes over the game time
    #
    function create_player_change(game_id::String, team_name::String, entity::SoccerPlayerChange, connection::SQLite.DB)
        SQLite.query(connection, "INSERT INTO changes VALUES ('$game_id', '$team_name', '$(entity.time)', '$(entity.nr1)', '$(entity.nr2)')")
    end

    #
    # Create players received fins
    #
    function create_player_fine(game_id::String, team_name::String, entity::SoccerFine, connection::SQLite.DB)
        SQLite.query(connection, "INSERT INTO fines VALUES ('$game_id', '$team_name', '$(entity.time)', '$(entity.nr)')")
    end


    #
    # Create players changes over the game time
    #
    function create_score(game_id::String, team_name::String, entity::SoccerScore, connection::SQLite.DB)
        SQLite.query(connection, "INSERT INTO scores VALUES ('$game_id', '$team_name', '$(entity.time)', '$(entity.nr)', '$(entity.score_type)')")
        map(x -> create_score_assist(game_id, team_name, entity, x, connection), entity.assistants)
    end

    #
    # Create list of score assistants
    #
    function create_score_assist(game_id::String, team_name::String, entity::SoccerScore, assist_id::Int64, connection::SQLite.DB)
        SQLite.query(connection, "INSERT INTO scores_assists VALUES ('$game_id', '$team_name', '$(entity.time)', '$(entity.nr)', '$assist_id')")
    end

    #
    # Get championship results table
    #
    function get_stats_game_table(connection::SQLite.DB)
        query = readstring("sql/get_stats_game_table.sql")
        SQLite.query(connection, query)
    end

    #
    # Get players rating
    #
    function get_stats_players_rating(connection::SQLite.DB)
        query = readstring("sql/get_stats_players_rating.sql")
        SQLite.query(connection, query)
    end

    #
    # Get list of top performing goalkeepers
    #
    function get_stats_goalkeepers_top(connection::SQLite.DB)
        query = readstring("sql/get_stats_goalkeepers_top.sql")
        SQLite.query(connection, query)
    end

    #
    # Get statistics on players fines
    #
    function get_stats_players_fines(connection::SQLite.DB)
        query = readstring("sql/get_stats_players_fines.sql")
        SQLite.query(connection, query)
    end

    #
    # Get statistics on team playes excep goalkeepers
    #
    function get_stats_team_players(team::String, connection::SQLite.DB)
        query = readstring("sql/get_stats_team.sql")
        query = replace(query, "{team_name}", team)
        SQLite.query(connection, query)
    end

    #
    # Get statistics on team goalkeepers
    #
    function get_stats_team_players_goalkeepers(team::String, connection::SQLite.DB)
        query = readstring("sql/get_stats_team_goalkeepers.sql")
        query = replace(query, "{team_name}", team)
        SQLite.query(connection, query)
    end

    #
    # Get strict judge rating
    #
    function get_stats_judge_rating(connection::SQLite.DB)
        query = readstring("sql/get_stats_judge_rating.sql")
        SQLite.query(connection, query)
    end

    #
    # Get statistics on replacements during the game within teams
    #
    function get_stats_teams_replaces(connection::SQLite.DB)
        query = readstring("sql/get_stats_teams_replacements.sql")
        SQLite.query(connection, query)
    end

    #
    # Get statistics on replacements during the game within teams
    #
    function get_stats_duplicated_players(connection::SQLite.DB)
        query = readstring("sql/get_stats_duplicated_players.sql")
        SQLite.query(connection, query)
    end

end
