module Main exposing (..)
import Http exposing(..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput,onClick)
import String


-- MAIN


main =
  Browser.element{ init = init, update = update, view = view, subscriptions = subscriptions}



-- MODEL


type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  , myUser : String
  , myPass : String
  , response : String
  }

init : () -> ( Model, Cmd Msg )
init _ = ({name="",password="",passwordAgain="",myUser="",myPass="",response=""}, testlab "" "")



-- UPDATE


type Msg
  = Name String
  | Password String
  | PasswordAgain String
  | ButtonPushed String String
  | GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Name name ->
      ({ model | name = name }, Cmd.none)

    Password password ->
      ({ model | password = password }, Cmd.none)

    PasswordAgain password ->
      ({ model | passwordAgain = password }, Cmd.none)
    
    ButtonPushed user password->
      ({ model | myUser = user, myPass = password}, testlab model.myUser model.myPass)

    GotText result ->
            case result of
                Ok val ->
                    ( { model | response = val }, Cmd.none)
                    
                Err error ->
                    (handleError model error , Cmd.none)

handleError model error =
    case error of
        Http.BadUrl url ->
            { model | response = "bad url: " ++ url }
            
        Http.Timeout ->
            { model | response = "timeout" }

        Http.NetworkError ->
            { model | response = "network error" }

        Http.BadStatus i ->
            { model | response = "bad status " ++ String.fromInt i }

        Http.BadBody body ->
            { model | response = "bad body " ++ body }

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Name" model.name Name
    , viewInput "password" "Password" model.password Password
    , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
    , viewValidation model
    , viewButton model.name model.password "Click Twice to Confirm"
    , viewText model.response
    ]

viewText : String -> Html Msg
viewText response = 
  div [] [text response]

viewButton : String -> String -> String -> Html Msg
viewButton name pass msg = 
  button [onClick (ButtonPushed name pass)] [text msg]

viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
  if model.password == model.passwordAgain then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]
    
testlab : String -> String -> Cmd Msg
testlab myUser myPass =
    Http.post
        { url = "https://mac1xa3.ca/e/zhua15/lab7/"
        , body = Http.stringBody "application/x-www-form-urlencoded" ("user="++myUser++"&password="++myPass)
        , expect = Http.expectString GotText
        }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none