module App exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Post =
    { title : String
    , body : String
    }


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , posts : List Post
    }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:post" "news:lobby" NewPostReceived


initialModel : Model
initialModel =
    { phxSocket = initPhxSocket
    , posts = []
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = AddPost Post
    | NewPostReceived Encode.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | JoinChannel
    | Dummy String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddPost post ->
            ( { model | posts = post :: model.posts }, Cmd.none )

        NewPostReceived raw ->
            case Decode.decodeValue postDecoder raw of
                Ok post ->
                    ( { model | posts = post :: model.posts }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "news:lobby"
                        |> Phoenix.Channel.onJoin (always (Dummy "done"))
                        |> Phoenix.Channel.onClose (always (Dummy "close"))

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

        Dummy str ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


postDecoder : Decode.Decoder Post
postDecoder =
    Pipeline.decode Post
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "body" Decode.string



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button
            [ onClick JoinChannel
            , class "btn btn-primary"
            ]
            [ text "Join to channel" ]
        , postListView model.posts
        ]


postView : Post -> Html Msg
postView post =
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ h4 [ class "card-title" ]
                [ text post.title
                ]
            , p [ class "card-text" ]
                [ text post.body
                ]
            ]
        ]


postListView : List Post -> Html Msg
postListView posts =
    div [ class "row" ]
        [ posts
            |> List.map postView
            |> div [ class "col-sm-12" ]
        ]
