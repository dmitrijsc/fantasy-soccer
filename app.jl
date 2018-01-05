# load all libraries
includes = ["src/source_file.jl", "src/entities.jl", "src/db.jl", "src/import_agent.jl", "src/input_source.jl"];
map(x -> include(x), includes);

# import required function
import InputSource: read_data_dir
import ImportAgent: import_all
import DB: create_connection, drop_tables, get_stats_game_table, get_stats_players_rating
import DB: get_stats_goalkeepers_top, get_stats_players_fines, get_stats_team_players
import DB: get_stats_team_players_goalkeepers, get_stats_judge_rating, get_stats_duplicated_players

# UI
println("Welcome to PD2!")
println("---------------")

# main functions
db_connection = DB.create_connection();
files = InputSource.read_data_dir();
ImportAgent.import_all(files, db_connection);

while true

    println("--------------------------------------")
    println("Please select your action (1-6): ")
    println("\t1. Update database from source files")
    println("\t2. Get results table")
    println("\t3. List best performing players")
    println("\t4. List best performing goalkeepers")
    println("\t5. List players with fines")
    println("\t6. Get team summary")
    println("\t7. List strict judges")
    println("\t8. Get team replacements statistics")
    println("\t9. Find duplicate players")
    println("\t10. Exit")
    println("--------------------------------------")
    println("")

    input = parse(Int64, readline(STDIN))

    if input == 1
        println("Updating database tables")
        files = InputSource.read_data_dir();
        ImportAgent.import_all(files, db_connection);
    elseif input == 2
        println("Tournament results")
        println(DB.get_stats_game_table(db_connection))
    elseif input == 3
        println("List of best performing players")
        println(DB.get_stats_players_rating(db_connection))
    elseif input == 4
        println("List of best performing players")
        println(DB.get_stats_goalkeepers_top(db_connection))
    elseif input == 5
        println("List of players with fines")
        println(DB.get_stats_players_fines(db_connection))
    elseif input == 6

        println("Please supply team name:")
        team_name = readline(STDIN)

        println("Regular players")
        println(DB.get_stats_team_players(team_name, db_connection))

        println("Goalkeepers")
        println(DB.get_stats_team_players_goalkeepers(team_name, db_connection))

    elseif input == 7
        println("List of strict judges")
        println(DB.get_stats_judge_rating(db_connection))
    elseif input == 8
        println("Team replacement statistics")
        println(DB.get_stats_teams_replaces(db_connection))
    elseif input == 9
        println("Duplicate players")
        println(DB.get_stats_duplicated_players(db_connection))
    elseif input == 10
        println("Thanks for using our software")
        break
    end

end
