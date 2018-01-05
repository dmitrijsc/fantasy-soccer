# Fantasy soccer

Fantasy soccer is a project developed during Modern Programming Languages course in University of Latvia as a part of a course work. 

## Project environment
Project is written and tested in Julia 0.6.1 and relies on SQLite database for storing game history.

## UI
Fantasy soccer relies on terminal screen to present data and read user inputs.

## Project structure
- ./data – location of source JSON files
-	./app.jl – main program file
-	./install.jl – prerequisite installation file
-	./sql – list of SQL queries
-	./src – custom libraries and controllers
-	./src/db.jl – SQLite db wrapper
-	./src/entities.jl – Fantasy Soccer entites/ object and their initialization
-	./src/import_agent.jl – import agent responsible for importing games into the database
-	./src/input_source.jl – data source search provider
-	./src/source_file.jl – JSON parser to Julia format
