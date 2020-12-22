@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

:: ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

:: ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

:: ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

:: ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev
set PROJECT_SSH_USER=somesshuser
set PROJECT_SSH_PASS=somesshpass

:: ------------------- execute script -------------------

call :main %*
goto end

:: ------------------- declare function -------------------

:main (
    call :argv-parser %*
    call :%BREADCRUMB%-args %COMMAND_BC_AGRS%
    call :main-args %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        call :main %COMMAND_AC_AGRS%
    ) else (
        call :%BREADCRUMB%
    )
    goto end
)
:main-args (
    for %%p in (%*) do (
        if "%%p"=="-h" ( set BREADCRUMB=%BREADCRUMB%-help )
        if "%%p"=="--help" ( set BREADCRUMB=%BREADCRUMB%-help )
    )
    goto end
)
:argv-parser (
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    set is_find_cmd=
    for %%p in (%*) do (
        IF NOT defined is_find_cmd (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
                set is_find_cmd=TRUE
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
    )
    goto end
)

:: ------------------- Main mathod -------------------

:cli (
    goto cli-help
)

:cli-args (
    goto end
)

:cli-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo.
    echo Command:
    echo      start             Start service with docker.
    echo      down              Stop service with docker.
    echo      vagrant           Start virtual machine with vagrant.
    echo      docker            Start virtual machine with docker.
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Command "start" mathod -------------------

:cli-start-docker-prepare (
    @rem Create .env for docker-compose
    echo Current Environment %PROJECT_ENV%
    echo TAG=%PROJECT_NAME% > .env

    goto end
)

:cli-start (
    call :cli-start-docker-prepare

    echo ^> Build ebook Docker images
    docker build --rm ^
        -t docker-ansible:%PROJECT_NAME% ^
        .\ansible

    echo ^> Generate SSH key
    IF NOT EXIST ssh-key (
        mkdir ssh-key
        docker run -ti --rm ^
          -v %cd%\ssh-key:/root/.ssh ^
          --name demo_service_ansible_%PROJECT_NAME% ^
          docker-ansible:%PROJECT_NAME% ^
          bash -l -c "ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa"
    )
    echo ^> Startup docker container instance
    @rem Run next deveopment with stdout
    docker run -ti --rm ^
        -v %cd%\ansible:/work ^
        -v %cd%\ssh-key:/root/.ssh ^
        --name demo_service_ansible_%PROJECT_NAME% ^
        docker-ansible:%PROJECT_NAME%

    goto end
)

:cli-start-args (
    for %%p in (%*) do (
        if "%%p"=="--dev" ( set DEVELOPER=1 )
    )
    goto end
)

:cli-start-help (
    echo Start service with docker compose.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- Command "down" mathod -------------------

:cli-down (
    @rem Close docker container instance by docker-compose
    docker-compose -f ./docker/docker-compose-%PROJECT_ENV%.yml down

    goto end
)

:cli-down-args (
    goto end
)

:cli-down-help (
    echo Close docker container instance by docker-compose.
    goto end
)

:: ------------------- Command "vagrant" mathod -------------------

:cli-vagrant (
    cd %CLI_DIRECTORY%\vagrant\ansible-vm-1
    vagrant up
    cd %CLI_DIRECTORY%\vagrant\ansible-vm-2
    vagrant up

    goto end
)

:cli-vagrant-args (
    goto end
)

:cli-vagrant-help (
    echo Start virtual machine with vagrant.
    goto end
)

:: ------------------- Command "docker" mathod -------------------

:cli-docker (
    echo ^> Build ebook Docker images
    docker build --rm ^
        -t docker-ansible-host:%PROJECT_NAME% ^
        .\docker

    docker rm -f demo_host_1_%PROJECT_NAME%
    docker run -d ^
        -v %cd%\ssh-key:/ssh-key ^
        --name demo_host_1_%PROJECT_NAME% ^
        docker-ansible-host:%PROJECT_NAME%
    echo ^> demo_host_1_%PROJECT_NAME% address :
    docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' demo_host_1_%PROJECT_NAME%

    docker rm -f demo_host_2_%PROJECT_NAME%
    docker run -d ^
        -v %cd%\ssh-key:/ssh-key ^
        --name demo_host_2_%PROJECT_NAME% ^
        docker-ansible-host:%PROJECT_NAME%
    echo ^> demo_host_2_%PROJECT_NAME% address :
    docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' demo_host_2_%PROJECT_NAME%

    goto end
)

:cli-docker-args (
    goto end
)

:cli-docker-help (
    echo Start virtual machine with docker.
    goto end
)

:: ------------------- End method-------------------

:end (
    endlocal
)
