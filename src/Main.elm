module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav exposing (Key)
import Html exposing (..)
import Html.Events exposing (..)
import Time exposing (every)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type alias Model =
    { points : Float
    , upgrades : Float
    , farms : Float
    , key : Key
    , route : Url
    }


defaultModel : Url -> (Key -> Model)
defaultModel url key =
    { points = 0
    , upgrades = 1
    , farms = 0
    , key = key
    , route = url
    }


init : flags -> (Url -> (Key -> ( Model, Cmd Msg )))
init _ url key =
    ( defaultModel url key
    , Cmd.none
    )


type Msg
    = Click
    | Upgrade
    | Buy
    | Tick Time.Posix
    | UrlChanged Url
    | LinkClicked UrlRequest
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( { model | route = url }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key <| Url.toString url )

                External url ->
                    ( model, Nav.load url )

        Click ->
            ( { model | points = model.points + (1 * model.upgrades) }
            , Cmd.none
            )

        Upgrade ->
            if upgradeCost model <= model.points then
                ( { model
                    | upgrades = model.upgrades + 1
                    , points = model.points - upgradeCost model
                  }
                , Cmd.none
                )

            else
                ( model
                , Cmd.none
                )

        Buy ->
            if farmCost model <= model.points then
                ( { model
                    | farms = model.farms + 1
                    , points = model.points - farmCost model
                  }
                , Cmd.none
                )

            else
                ( model
                , Cmd.none
                )

        Tick _ ->
            ( { model | points = model.points + model.farms }
            , Cmd.none
            )

        NoOp ->
            ( model
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    every 1000 Tick


cost : Float -> Float -> Float -> Float
cost num power factor =
    num
        |> (^) power
        |> (*) factor


upgradeCost : Model -> Float
upgradeCost model =
    cost model.upgrades 1.4 15


farmCost : Model -> Float
farmCost model =
    cost model.farms 1.2 10


showFloat : Float -> String
showFloat num =
    num
        |> round
        |> String.fromInt


view : Model -> Browser.Document Msg
view model =
    { title = "Hello World"
    , body =
        [ div []
            [ h1 [] [ text <| showFloat model.points ]
            , button [ onClick Click ] [ text "click for points" ]
            , button [ onClick Upgrade ] [ text <| "upgrade clicker for " ++ (showFloat <| upgradeCost model) ++ " points" ]
            , button [ onClick Buy ] [ text <| "buy clicker for " ++ (showFloat <| farmCost model) ++ " points" ]
            ]
        ]
    }
