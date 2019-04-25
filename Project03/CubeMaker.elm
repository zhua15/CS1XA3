import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import Random exposing (..)
import List exposing (..)
import Http
import Json.Encode as E
import Json.Decode as D
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

alice = RGBA 240 248 255 1
black = RGBA 0 0 0 1
blue = RGBA 70 130 180 1
brown = RGBA 139 69 19 1
green = RGBA 0 128 0 1
grey = RGBA 128 128 128 1
lime = RGBA 0 256 0 1
maroon = RGBA 128 0 0 1
olive =RGBA 128 128 0 1
orange =RGBA 255 140 0 1
purple = RGBA 186 85 211 1
pink = RGBA 248 24 148 1
red = RGBA 256 0 0 1
sky = RGBA 179 228 239 1
sea = RGBA 46 139 87 1
teal = RGBA 0 128 128 1
yellow = RGBA 204 204 0 1

g = 0.1
a = 0.06
friction = 0.03
jumpStrength = 2
initialPlatforms = [((-20,-4),(-38,-36),red),((-4,30),(-39,-38),blue),((-10,10),(-16,-14),purple),((20,30),(6,8),orange),((-10,0),(20,22),grey)]
numplayers = 2 -- will increase player limit beyond 2 soon
playerColours = ((purple,blue),(red,green))
cubesize = 3
startposx = ((-25,-10),(10,25))
startposy = ((-38,-38),(-38,-38))
wincolour = grey

type Msg = Tick Float GetKeyState
         | SaveTap
         | LoadTap
         | NewTap
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | GotSave (Result Http.Error String)
         | GotLoad (Result Http.Error PlatformTuples)
         | Username String
         | Password String
         | PasswordConfirm String
         | SignupTap
         | LoginTap
         | LoginButton
         | SignupButton
         | GotAuth (Result Http.Error String)
         | Length String
         | Width String
         | Colour Colour
         | AddPlatform
         | PlayAgain
         | PlatformMoveStart (Float,Float)
         | PlatformMoving Int (Float,Float)
         | PlatformMoveEnd
         | Logout

type alias Model = 
    {
        page : Page,
        player1 : (Bool,Colour),
        player2 : (Bool,Colour),
        player3 : (Bool,Colour),
        player4 : (Bool,Colour),
        velx : FourTuples,
        vely : FourTuples,
        posx : FourTuples,
        posy : FourTuples,
        platform : PlatformTuples,
        username : String,
        password : String,
        confirmpassword : String,
        length : String,
        width : String,
        pcolour : Colour,
        pstartx : Float,
        pstarty : Float,
        pnum : Int,
        pmovable : Bool,
        response : String
    }

type Page = Login | Signup | Game | YouWin

type Colour = RGBA Int Int Int Float

type alias PlatformTuples = List ((Float,Float),(Float,Float),Colour)

type alias FourTuples = ((Float,Float),(Float,Float))

init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =    let
                            ((c1,c2),(c3,c4)) = playerColours
                        in
                        ({
                        page = Login,
                        player1 = if numplayers >= 1 then (True,c1) else (False,(RGBA 0 0 0 0)),
                        player2 = if numplayers >= 2 then (True,c2) else (False,(RGBA 0 0 0 0)),
                        player3 = if numplayers >=3 then (True,c3) else (False,(RGBA 0 0 0 0)),
                        player4 = if numplayers >=4 then (True,c4) else (False,(RGBA 0 0 0 0)),
                        velx  = ((0,0),(0,0)),
                        vely = ((0,0),(0,0)),
                        posx = startposx,
                        posy = startposy,
                        username = "",
                        password = "",
                        confirmpassword = "",
                        length = "",
                        width = "",
                        platform = initialPlatforms,
                        pcolour = black,
                        pstartx = 0,
                        pstarty = 0,
                        pnum = 0,
                        pmovable = False,
                        response = ""
                        }, Cmd.none) 


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        Tick time (keyToState,(arrowX,arrowY),(wasdX,wasdY)) -> 
            let
                (isAlive1,colour1) = model.player1
                (isAlive2,colour2) = model.player2
                (isAlive3,colour3) = model.player3
                (isAlive4,colour4) = model.player4
                velx1new = velxUpdate model.posx model.posy model.velx model.vely wasdX isAlive1 1 model.platform
                posx1new = posxUpdate model.posx model.posy model.velx model.vely isAlive1 1 model.platform
                vely1new = velyUpdate model.posx model.posy model.velx model.vely wasdY isAlive1 1 model.platform
                posy1new = posyUpdate model.posx model.posy model.velx model.vely isAlive1 1 model.platform
                velx2new = velxUpdate model.posx model.posy model.velx model.vely arrowX isAlive2 2 model.platform
                posx2new = posxUpdate model.posx model.posy model.velx model.vely isAlive2 2 model.platform
                vely2new = velyUpdate model.posx model.posy model.velx model.vely arrowY isAlive2 2 model.platform
                posy2new = posyUpdate model.posx model.posy model.velx model.vely isAlive2 2 model.platform
                velx3new = velxUpdate model.posx model.posy model.velx model.vely 0 isAlive3 3 model.platform -- 2 player for now
                posx3new = posxUpdate model.posx model.posy model.velx model.vely isAlive3 3 model.platform
                vely3new = velyUpdate model.posx model.posy model.velx model.vely 0 isAlive3 3 model.platform
                posy3new = posyUpdate model.posx model.posy model.velx model.vely isAlive3 3 model.platform
                velx4new = velxUpdate model.posx model.posy model.velx model.vely 0 isAlive4 4 model.platform
                posx4new = posxUpdate model.posx model.posy model.velx model.vely isAlive4 4 model.platform
                vely4new = velyUpdate model.posx model.posy model.velx model.vely 0 isAlive4 4 model.platform
                posy4new = posyUpdate model.posx model.posy model.velx model.vely isAlive4 4 model.platform
            in  if (isWin model model.platform) == True then
                    ({model | page = YouWin}, Cmd.none)
                else 
                    ({model | posx = ((posx1new,posx2new),(posx3new,posx4new)), velx = ((velx1new,velx2new),(velx3new,velx4new)), posy = ((posy1new,posy2new),(posy3new,posy4new)), vely = ((vely1new,vely2new),(vely3new,vely4new))}, Cmd.none)

        Length input -> ({ model | length = input }, Cmd.none)
        Width input -> ({ model | width = input }, Cmd.none)
        Colour input -> ({model | pcolour = input}, Cmd.none)
        AddPlatform -> 
            let
                xmin = (String.toFloat model.length)
                xmax = (String.toFloat model.length)
                ymin = (String.toFloat model.width)
                ymax = (String.toFloat model.width)
                xminhalf = case xmin of
                                Just x -> -0.5*x
                                Nothing -> 0
                xmaxhalf = case xmax of
                                Just x -> 0.5*x
                                Nothing -> 0
                yminhalf = case ymin of
                                Just x -> -0.5*x
                                Nothing -> 0
                ymaxhalf = case ymax of
                                Just x -> 0.5*x
                                Nothing -> 0
            in  if xminhalf >= 0 || yminhalf >= 0 then
                    (model, Cmd.none)
                else
                    ({model | platform = model.platform ++ [((xminhalf,xmaxhalf),(yminhalf,ymaxhalf),model.pcolour)]}, Cmd.none)
            
        SaveTap -> (model, sendJsonPost model.platform)
        LoadTap -> (model, getJsonPost model)
        NewTap -> ({ model | platform = [], page = Game}, Cmd.none)
        Logout -> ({ model | page = Login}, Cmd.none)

        Username input -> ({ model | username = input }, Cmd.none)
        Password input -> ({ model | password = input }, Cmd.none)
        PasswordConfirm input -> ({ model | confirmpassword = input }, Cmd.none)

        LoginButton -> (model, loginPost model)
        SignupButton -> if model.confirmpassword == model.password then
                            (model, signupPost model)
                        else
                            (model, Cmd.none)
        PlayAgain -> ({model | page = Game}, Cmd.none)
        PlatformMoveStart (x,y) -> ({model | pstartx = x, pstarty = y, pmovable = True}, Cmd.none)
        PlatformMoving pnum (x,y) -> 
            let
                movex = x - model.pstartx
                movey = y - model.pstarty
                toChange =  if pnum == 1 then
                                case head(model.platform) of
                                    Just anything -> anything
                                    _ -> ((0,0),(0,0),blue)
                            else
                                case head(drop (pnum-1) (take pnum model.platform)) of
                                    Just anything -> anything
                                    _ -> ((0,0),(0,0),blue)
                ((xmin,xmax),(ymin,ymax),colour) = toChange
                mouseMoveX = x - model.pstartx
                mouseMoveY = y - model.pstarty
                newPlatform =   if x <= -40 && x >= -50 && y <= -10 && y >= -40 then
                                    []
                                else
                                    [((xmin+mouseMoveX,xmax+mouseMoveX),(ymin+mouseMoveY,ymax+mouseMoveY),colour)]
                inFront =   if pnum == 1 then
                                []
                            else
                                take (pnum-1) model.platform
                inBack =    drop pnum model.platform
                newplatforms = inFront ++ newPlatform ++ inBack
            in 
            if model.pmovable == True then
                ({model | platform = newplatforms, pstartx = x, pstarty = y},Cmd.none)
            else
                (model, Cmd.none)

        PlatformMoveEnd -> ({model | pmovable = False}, Cmd.none)

        SignupTap -> ({model | page = Signup, username = "", password = "", confirmpassword = "", response = ""}, Cmd.none)
        LoginTap ->  ({model | page = Login, username = "", password = "", confirmpassword = "", response = ""}, Cmd.none)

        MakeRequest req -> (model, Cmd.none)
        UrlChange url -> (model, Cmd.none)

        GotAuth result ->
            case result of
                Ok "Login Success" -> ({model | page = Game} , Cmd.none)
                Ok _ -> ({model | response = ""}, Cmd.none)
                Err error -> (handleError model error , Cmd.none)

        GotSave result ->
            case result of
                Ok "Save Success" -> (model,Cmd.none)
                Ok _ -> (model, Cmd.none)
                Err error -> (handleError model error , Cmd.none)

        GotLoad result ->
            case result of
                Ok val -> ({model | platform = val}, Cmd.none)
                Err error -> (handleError model error , Cmd.none)

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
            { model | response = "bad body " ++ body}


view : Model -> { title : String, body : Collage Msg }
view model = 
    let
        title = "CubeMaker"
        body = collage 100 100 whichScreen
        whichScreen = case model.page of
                        Login -> loginScreen
                        Signup -> signupScreen
                        Game -> gameScreen
                        YouWin -> gameScreen ++ [GraphicSVG.text "You Win!" |> GraphicSVG.size 10 |> GraphicSVG.filled GraphicSVG.black |> move (-20,0)]
                    
        loginScreen = notgamebackground ++ usernameBox ++ passwordBox ++ loginButton ++ toSignup ++ errorDisplay
        signupScreen = notgamebackground ++ [group (usernameBox ++ passwordBox ++ confirmpasswordBox ++ signupButton) |> move (0,10)] ++ toLogin ++ [group(errorDisplay) |> move (0,-5)]
        usernameBox = [html 50 50 (div [] [input [ Html.Attributes.style "font-size" "2px", Html.Attributes.style "height" "3px", Html.Attributes.style "width" "25px", placeholder "Username", value model.username, onInput Username ] []]) |> move (-15,15)]
        passwordBox = [html 50 50 (div [] [input [ Html.Attributes.style "font-size" "2px", Html.Attributes.style "height" "3px", Html.Attributes.style "width" "25px", placeholder "Password", Html.Attributes.type_ "password", value model.password, onInput Password ] []]) |> move (-15,0)]
        confirmpasswordBox = [html 50 50 (div [] [input [ Html.Attributes.style "font-size" "2px", Html.Attributes.style "height" "3px", Html.Attributes.style "width" "25px", placeholder "Confirm Password", Html.Attributes.type_ "password", value model.confirmpassword, onInput PasswordConfirm ] []]) |> move (-15,-15)]
        loginButton = [rectangle 20 10 |> filled white |> move (0,-30) |> notifyTap LoginButton] ++ [GraphicSVG.text "Login" |> GraphicSVG.size 5 |> filled (toSVG black) |> move (-6,-31.5) |> notifyTap LoginButton]
        signupButton =  [rectangle 20 10 |> filled white |> move (0,-45) |> notifyTap SignupButton] ++ [GraphicSVG.text "Sign Up" |> GraphicSVG.size 5 |> filled (toSVG black) |> move (-8,-47) |> notifyTap SignupButton]
        toSignup = [GraphicSVG.text "Not a user?" |> GraphicSVG.size 2 |> filled (toSVG black) |> move (35,-45) |> notifyTap SignupTap]
        toLogin = [GraphicSVG.text "Already a user?" |> GraphicSVG.size 2 |> filled (toSVG black) |> move (30,-45) |> notifyTap LoginTap]
        notgamebackground = [square 100|> filled (toSVG sky)]

        errorDisplay = [GraphicSVG.text model.response |> GraphicSVG.size 2 |> filled (toSVG black) |> move (-6,-40)]
        
        gameScreen = background ++ playergroup ++ playerModelGroup ++ border ++ buttons ++ addplatformAll ++ delete ++ platforms
        background = [square 80 |> filled (toSVG alice)]
        border = [square 80 |> outlined (solid 1) GraphicSVG.black]

        playergroup = player1 ++ player2 ++ player3 ++ player4
        player1 = ifPlayer model (-45,45) 1
        player2 = ifPlayer model (45,45) 2
        player3 = ifPlayer model (-45,-45) 3
        player4 = ifPlayer model (45,-45) 4

        playerModelGroup = playerModel1 ++ playerModel2 ++ playerModel3 ++ playerModel4
        playerModel1 = playerPiece model 1
        playerModel2 = playerPiece model 2
        playerModel3 = playerPiece model 3
        playerModel4 = playerPiece model 4

        platforms = (platformGenerate 1 model.platform)
        addplatformLength = [html 20 20 (div [] [input [ Html.Attributes.style "font-size" "3px", Html.Attributes.style "height" "3px", Html.Attributes.style "width" "5px", placeholder "L", value model.length, onInput Length ] []]) |> move (-15,43)]
        addplatformWidth = [html 20 20 (div [] [input [ Html.Attributes.style "font-size" "3px", Html.Attributes.style "height" "3px", Html.Attributes.style "width" "5px", placeholder "W", value model.width, onInput Width ] []]) |> move (-15,28)]
        addplatformColour = [square 3 |> filled (toSVG blue) |> move (-9, -10) |> notifyTap (Colour blue)] ++ [square 3 |> filled (toSVG sky) |> move (-13, -10) |> notifyTap (Colour sky)] ++ 
                            [square 3 |> filled (toSVG orange) |> move (-9, -14) |> notifyTap (Colour orange)] ++ [square 3 |> filled (toSVG purple) |> move (-13, -14) |> notifyTap (Colour purple)] ++ 
                            [square 3 |> filled (toSVG black) |> move (-9, -18) |> notifyTap (Colour black)] ++ [square 3 |> filled(toSVG green) |> move (-13, -18) |> notifyTap (Colour green)] ++ 
                            [square 3 |> filled (toSVG red) |> move (-9, -22) |> notifyTap (Colour red)] ++ [square 3 |> filled (toSVG pink) |> move (-13, -22) |> notifyTap (Colour pink)] ++
                            [square 3 |> filled (toSVG brown) |> move (-9, -26) |> notifyTap (Colour brown)] ++ [square 3 |> filled (toSVG maroon) |> move (-13, -26) |> notifyTap (Colour maroon)] ++ 
                            [square 3 |> filled (toSVG olive) |> move (-9, -30) |> notifyTap (Colour olive)] ++ [square 3 |> filled (toSVG teal) |> move (-13, -30) |> notifyTap (Colour teal)] ++ 
                            [square 3 |> filled (toSVG yellow) |> move (-9, -34) |> notifyTap (Colour yellow)] ++ [square 3 |> filled(toSVG grey) |> move (-13, -34) |> notifyTap (Colour grey)] ++ 
                            [square 3 |> filled (toSVG sea) |> move (-9, -38) |> notifyTap (Colour sea)] ++ [square 3 |> filled (toSVG lime) |> move (-13, -38) |> notifyTap (Colour lime)]
        winColour = [GraphicSVG.text "V" |> GraphicSVG.size 3 |> filled (toSVG black) |> move (41.9, -35) |> notifyTap (Colour wincolour)]
        addplatformButton = [rectangle 8 8 |> filled GraphicSVG.grey |> move (-11, -2) |> notifyTap AddPlatform ] ++ [GraphicSVG.text "Add" |> GraphicSVG.size 3|> filled GraphicSVG.black |> move (-14, -3) |> notifyTap AddPlatform ]
        addplatformAll = [group (addplatformLength ++ addplatformWidth ++ addplatformColour ++ addplatformButton) |> move (56,0)] ++ winColour
        delete = [square 7 |> filled GraphicSVG.grey |> move (-45,-25)] ++ [rectangle 8 2 |> filled GraphicSVG.grey |> move (-45,-20)] ++ [rectangle 3 0.5 |> filled GraphicSVG.grey |> move (-45,-19)] ++ [rectangle 10 15 |> outlined (solid 0.2) GraphicSVG.black |> move (-45,-25)]

        buttons = [group[save,load,new,saveText,loadText,newText,logoutText]]
        logoutText = GraphicSVG.text "Logout" |>  GraphicSVG.size 3 |> filled GraphicSVG.black |> move (0, 45) |> notifyTap Logout
        saveText = GraphicSVG.text "Save" |>  GraphicSVG.size 3 |> filled GraphicSVG.black |> move (-48, 7) |> notifyTap SaveTap
        loadText = GraphicSVG.text "Load" |>  GraphicSVG.size 3 |> filled GraphicSVG.black |> move (-48, -1) |> notifyTap LoadTap
        newText = GraphicSVG.text "New" |>  GraphicSVG.size 3 |> filled GraphicSVG.black |> move (-48, -9) |> notifyTap NewTap
        save =  square 7 |> filled GraphicSVG.grey |> move (-45,8) |> notifyTap SaveTap
        load = square 7 |> filled GraphicSVG.grey |> move (-45,0) |> notifyTap LoadTap
        new = square 7 |> filled GraphicSVG.grey |> move (-45,-8) |> notifyTap NewTap
        

    in { title = title , body = body }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : AppWithTick () Model Msg
main = appWithTick Tick
       { init = init
       , update = update
       , view = view
       , subscriptions = subscriptions
       , onUrlRequest = MakeRequest
       , onUrlChange = UrlChange
       }

---------------------------------------Functions

ifPlayer : Model -> (Float, Float) -> Int -> List (Shape userMsg)
ifPlayer model (x,y) playernum = 
    let
        (playerbool, playercolour) =    if playernum == 1 then
                                            model.player1
                                        else if playernum == 2 then
                                            model.player2
                                        else if playernum == 3 then
                                            model.player3
                                        else
                                            model.player4
        icon = group [square 8 |> filled (toSVG playercolour), iconame] |> move (x,y)
        iconame = GraphicSVG.text (String.fromInt playernum) |>  GraphicSVG.size 3 |> filled white |> move (-0.5,-0.7)
    in 
    if playerbool then
        [icon]
    else
        []

playerPiece : Model -> Int -> List (Shape userMsg)
playerPiece model playernum =
    let
        ((posx1,posx2),(posx3,posx4)) = model.posx
        ((posy1,posy2),(posy3,posy4)) = model.posy
        (playerbool, playercolour)= if playernum == 1 then
                                        model.player1
                                    else if playernum == 2 then
                                        model.player2
                                    else if playernum == 3 then
                                        model.player3
                                    else
                                        model.player4
        posx =  if playernum == 1 then
                    posx1
                else if playernum == 2 then
                    posx2
                else if playernum == 3 then
                    posx3
                else
                    posx4
        posy =  if playernum == 1 then
                    posy1
                else if playernum == 2 then
                    posy2
                else if playernum == 3 then
                    posy3
                else
                    posy4
    in 
    if playerbool then
        [square cubesize |> filled (toSVG playercolour) |> move (posx,posy)]
    else []

---easier to add new walls and collidable objects

--future player collision implementation
--otherPlayers =  if num == 1 then
--                    [(posx2-(cubesize/2),posx2+(cubesize/2),posy2),(posx3-(cubesize/2),posx3+(cubesize/2),posy3),(posx4-(cubesize/2),posx4+(cubesize/2),posy4)]
--                else if num == 2 then
--                    [(posx1-(cubesize/2),posx1+(cubesize/2),posy1),(posx3-(cubesize/2),posx3+(cubesize/2),posy3),(posx4-(cubesize/2),posx4+(cubesize/2),posy4)]
--                else if num == 3 then
--                    [(posx1-(cubesize/2),posx1+(cubesize/2),posy1),(posx2-(cubesize/2),posx2+(cubesize/2),posy2),(posx4-(cubesize/2),posx4+(cubesize/2),posy4)]
--                else
--                   [(posx1-(cubesize/2),posx1+(cubesize/2),posy1),(posx2-(cubesize/2),posx2+(cubesize/2),posy2),(posx3-(cubesize/2),posx3+(cubesize/2),posy3)]

velxUpdate : FourTuples -> FourTuples -> FourTuples -> FourTuples -> Float -> Bool -> Int -> PlatformTuples -> Float
velxUpdate ((posx1,posx2),(posx3,posx4)) ((posy1,posy2),(posy3,posy4)) ((velx1,velx2),(velx3,velx4)) ((vely1,vely2),(vely3,vely4)) key isAlive num myPlatforms =    
    let
        posx =  if num == 1 then posx1 else if num == 2 then posx2 else if num == 3 then posx3 else posx4
        posy =  if num == 1 then posy1 else if num == 2 then posy2 else if num == 3 then posy3 else posy4
        velx =  if num == 1 then velx1 else if num == 2 then velx2 else if num == 3 then velx3 else velx4
        vely =  if num == 1 then vely1 else if num == 2 then vely2 else if num == 3 then vely3 else vely4
    in
    if isAlive == False then
        0
    else if posx +velx > (39.5 - (cubesize/2)) then
        0
    else if posx + velx < -(39.5 - (cubesize/2)) then
        0
    else if abs(velx) < 0.03 then
        0 + a*key
    else if helperVelx posx posy velx myPlatforms then
        0
    else if velx > 0 then
        velx + a*key - friction
    else if velx < 0 then
        velx + a*key + friction
    else
        velx + a*key

velyUpdate : FourTuples -> FourTuples -> FourTuples -> FourTuples -> Float -> Bool -> Int -> PlatformTuples -> Float
velyUpdate ((posx1,posx2),(posx3,posx4)) ((posy1,posy2),(posy3,posy4)) ((velx1,velx2),(velx3,velx4)) ((vely1,vely2),(vely3,vely4)) key isAlive num myPlatforms =    
    let
        posx =  if num == 1 then posx1 else if num == 2 then posx2 else if num == 3 then posx3 else posx4
        posy =  if num == 1 then posy1 else if num == 2 then posy2 else if num == 3 then posy3 else posy4
        velx =  if num == 1 then velx1 else if num == 2 then velx2 else if num == 3 then velx3 else velx4
        vely =  if num == 1 then vely1 else if num == 2 then vely2 else if num == 3 then vely3 else vely4
    in 
    if isAlive == False then
        0
    else if key == 1 && (posy == -(39.5 - (cubesize/2)) || isPlatform posx posy myPlatforms) then
        jumpStrength
    else
        if posy +vely >= (39.5 - (cubesize/2)) then
            0-g
        else if posy +vely < -(39.5 - (cubesize/2)) then
            0
        else
            if helperVelyT posx posy vely myPlatforms then
                0-g
            else if helperVelyB posx posy vely myPlatforms then
                0-g
            else
                vely-g

posxUpdate : FourTuples -> FourTuples -> FourTuples -> FourTuples -> Bool -> Int -> PlatformTuples -> Float
posxUpdate ((posx1,posx2),(posx3,posx4)) ((posy1,posy2),(posy3,posy4)) ((velx1,velx2),(velx3,velx4)) ((vely1,vely2),(vely3,vely4)) isAlive num myPlatforms =    
    let
        posx =  if num == 1 then posx1 else if num == 2 then posx2 else if num == 3 then posx3 else posx4
        posy =  if num == 1 then posy1 else if num == 2 then posy2 else if num == 3 then posy3 else posy4
        velx =  if num == 1 then velx1 else if num == 2 then velx2 else if num == 3 then velx3 else velx4
        vely =  if num == 1 then vely1 else if num == 2 then vely2 else if num == 3 then vely3 else vely4
    in 
    if isAlive == False then
        -300
    else
        let
            (isTrueL,numL) = helperPosxL posx posy velx myPlatforms
            (isTrueR,numR) = helperPosxR posx posy velx myPlatforms
        in
        if isTrueL then
            numL
        else if isTrueR then
            numR
        else
            if posx+velx < -(39.5 - (cubesize/2)) then
                -(39.5 - (cubesize/2))
            else if posx+velx > (39.5 - (cubesize/2)) then
                (39.5 - (cubesize/2))
            else
                posx + velx

posyUpdate : FourTuples -> FourTuples -> FourTuples -> FourTuples ->Bool -> Int -> PlatformTuples -> Float
posyUpdate ((posx1,posx2),(posx3,posx4)) ((posy1,posy2),(posy3,posy4)) ((velx1,velx2),(velx3,velx4)) ((vely1,vely2),(vely3,vely4)) isAlive num myPlatforms =    
    let
        posx =  if num == 1 then posx1 else if num == 2 then posx2 else if num == 3 then posx3 else posx4
        posy =  if num == 1 then posy1 else if num == 2 then posy2 else if num == 3 then posy3 else posy4
        velx =  if num == 1 then velx1 else if num == 2 then velx2 else if num == 3 then velx3 else velx4
        vely =  if num == 1 then vely1 else if num == 2 then vely2 else if num == 3 then vely3 else vely4
    in
    if isAlive == False then
        -300
    else
        let
            (isTrueT,numT) = helperPosyT posx posy vely myPlatforms
            (isTrueB,numB) = helperPosyB posx posy vely myPlatforms
            (isTrueC,numC) = clipperCorner posx posy velx vely myPlatforms
        in 
        if isTrueT then
            numT
        else if isTrueB then
            numB
        else if isTrueC then
            numC 
        else
            if posy+vely < -(39.5 - (cubesize/2)) then
                -(39.5 - (cubesize/2))
            else if posy+vely > (39.5 - (cubesize/2)) then
                (39.5 - (cubesize/2))
            else
                posy + vely

helperVelx : Float -> Float -> Float -> PlatformTuples -> Bool   
helperVelx posx posy velx x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            False
        else
            helperVelx posx posy velx x2 || posy > ymin - cubesize/2 && posy < ymax + cubesize/2 && (posx == xmin - (cubesize/2) || posx == xmax + (cubesize/2))

helperVelyT : Float -> Float -> Float -> PlatformTuples -> Bool
helperVelyT posx posy vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            False
        else
            (helperVelyT posx posy vely x2) || (posy == ymax + cubesize/2 && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) && vely < 0)

helperVelyB : Float -> Float -> Float ->PlatformTuples -> Bool
helperVelyB posx posy vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            False
        else
            (helperVelyB posx posy vely x2) || (posy == ymin - cubesize/2 && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) && vely > 0)

helperPosxL : Float -> Float -> Float -> PlatformTuples -> (Bool,Float)
helperPosxL posx posy velx x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            (False,0)
        else if  posy > ymin - cubesize/2 && posy < ymax + cubesize/2 && posx <= xmin - (cubesize/2) && posx + velx > xmin - (cubesize/2) then
            (True, xmin - (cubesize/2))
        else
            (helperPosxL posx posy velx x2)

helperPosxR : Float -> Float -> Float -> PlatformTuples -> (Bool,Float)
helperPosxR posx posy velx x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            (False,0)
        else if posy > ymin - cubesize/2 && posy < ymax + cubesize/2 && posx >= xmax + (cubesize/2) && posx + velx < xmax + (cubesize/2) then
            (True, xmax + (cubesize/2))
        else
            (helperPosxR posx posy velx x2)

helperPosyT : Float -> Float -> Float -> PlatformTuples -> (Bool,Float)
helperPosyT posx posy vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            (False,0)
        else if posy >= ymax + cubesize/2 && posy + vely < ymax + cubesize/2  && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) && vely < 0 then
            (True, ymax + cubesize/2)
        else
            (helperPosyT posx posy vely x2)

helperPosyB : Float -> Float -> Float -> PlatformTuples -> (Bool,Float)
helperPosyB posx posy vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            (False,0)
        else if posy <= ymin - cubesize/2 && posy + vely > ymin - cubesize/2  && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) && vely > 0 then
            (True, ymin - cubesize/2)
        else
            (helperPosyB posx posy vely x2)

clipperCorner : Float -> Float -> Float -> Float -> PlatformTuples -> (Bool,Float)
clipperCorner posx posy velx vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            (False,0)
        else if posy > ymin - cubesize/2 && posy < ymax + cubesize/2 && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) then
            if posy >= ymax then
                (True, ymax + cubesize/2)
            else
                (True, ymin - cubesize/2)
        else
            (clipperCorner posx posy velx vely x2)

helperCornerV : Float -> Float -> Float -> Float -> PlatformTuples -> Bool
helperCornerV posx posy velx vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),(RGBA 0 0 0 0)) then
            False
        else if True then
            True
        else
            (helperCornerV posx posy velx vely x2)

isPlatform : Float -> Float -> PlatformTuples -> Bool
isPlatform posx posy x =
    let
        header = case head(x) of
                    Just v -> v
                    Nothing -> ((300,300),(300,300),(RGBA 0 0 0 0))
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((300,300),(300,300),(RGBA 0 0 0 0)) then
            False
        else if posy == ymax + cubesize/2 && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) then
            True
        else
            isPlatform posx posy x2

platformGenerate : Int -> PlatformTuples -> List (Shape Msg)
platformGenerate pnum platformList = 
    let
        header =  case head(platformList) of
                    Just v -> v
                    Nothing -> ((300,300),(300,300),(RGBA 0 0 0 0))

        ((xmin,xmax),(ymin,ymax),colour) = header
        
        x2 = case tail(platformList) of
                Just v -> v
                Nothing -> []
    in 
    if x2 /= [] then
        [rectangle (abs(xmax - xmin)) (abs(ymax - ymin)) |> filled (toSVG colour) |> move (((xmin + xmax)/2),((ymax + ymin)/2)) |> notifyMouseDownAt PlatformMoveStart |> notifyMouseMoveAt (PlatformMoving pnum) |> notifyMouseUp PlatformMoveEnd |> notifyLeave PlatformMoveEnd] ++ platformGenerate (pnum + 1) x2
    else
        [rectangle (abs(xmax - xmin)) (abs(ymax - ymin)) |> filled (toSVG colour) |> move (((xmin + xmax)/2),((ymax + ymin)/2)) |> notifyMouseDownAt PlatformMoveStart |> notifyMouseMoveAt (PlatformMoving pnum) |> notifyMouseUp PlatformMoveEnd |> notifyLeave PlatformMoveEnd]

isWin : Model -> PlatformTuples -> Bool
isWin model platform =
    let
        header =  case head(platform) of
                    Just v -> v
                    Nothing -> ((300,300),(300,300),(RGBA 0 0 0 0))

        ((xmin,xmax),(ymin,ymax),colour) = header
        tailer = case tail(platform) of
                Just v -> v
                Nothing -> []
        ((x1,x2),(x3,x4)) = model.posx
        ((y1,y2),(y3,y4)) = model.posy
    in
    if tailer == [] && header == ((300,300),(300,300),(RGBA 0 0 0 0)) then
        False
    else if (y1 == ymax + cubesize/2 || y2 == ymax + cubesize/2 || y3 == ymax + cubesize/2 || y4 == ymax + cubesize/2 )
            && (x1 > xmin - (cubesize/2) || x2 > xmin - (cubesize/2) || x3 > xmin - (cubesize/2) || x4 > xmin - (cubesize/2))
            && (x1 < xmax + (cubesize/2) || x2 < xmax + (cubesize/2) || x3 < xmax + (cubesize/2) || x4 < xmax + (cubesize/2))
            && colour == wincolour then
        True
    else
        isWin model tailer

--------------------- server stuff

encodeColour : Colour -> E.Value
encodeColour (RGBA r gr b al) =
    E.object
        [
            ("r",E.int r)
        ,   ("g",E.int gr)
        ,   ("b",E.int b)        
        ,   ("a",E.float al)        
        ]

encodeDoubleTuple : (Float,Float) -> E.Value
encodeDoubleTuple (fst,snd) =
    E.object
        [
            ("f", E.float fst)
        ,   ("s", E.float snd)
        ]

encodeTripleTuple : ((Float,Float),(Float,Float),Colour) -> E.Value
encodeTripleTuple (xval,yval,colour) = 
    E.object
        [
            ("xvals", encodeDoubleTuple xval),
            ("yvals", encodeDoubleTuple yval),
            ("colours", encodeColour colour)
        ]

encodeList : List ((Float,Float),(Float,Float),Colour) -> E.Value
encodeList platforms = 
    E.object
        [
            ("platforms", E.list encodeTripleTuple platforms)
        ]

encodeCredentials : Model -> E.Value
encodeCredentials model = 
    E.object
        [
            ("username", E.string model.username),
            ("password", E.string model.password)
        ]

decodeColour : D.Decoder Colour
decodeColour =
    D.map4 RGBA (D.field "r" D.int) (D.field "g" D.int) (D.field "b" D.int) (D.field "a" D.float)        

decodeDoubleTuple : D.Decoder (Float,Float)
decodeDoubleTuple=
    D.map2 Tuple.pair (D.field "f" D.float) (D.field "s" D.float)

decodeTripleTuple : D.Decoder ((Float,Float),(Float,Float),Colour)
decodeTripleTuple = 
    D.map3 (\x b c -> (x,b,c)) (D.field "xvals" decodeDoubleTuple) (D.field "yvals" decodeDoubleTuple) (D.field "colours" decodeColour) 

decodeList : D.Decoder PlatformTuples
decodeList = 
    D.field "platforms" (D.list decodeTripleTuple)

toSVG : Colour -> Color
toSVG myColour = case myColour of
                    RGBA rr gg bb aa -> rgba (toFloat rr) (toFloat gg) (toFloat bb) aa

loginPost : Model -> Cmd Msg
loginPost model = 
    Http.post
        {
            url = "https://mac1xa3.ca/e/zhua15/Project03/login/",
            body = Http.jsonBody <| encodeCredentials model,
            expect = Http.expectString GotAuth 
        }

logoutPost : Cmd Msg
logoutPost =
    Http.get
        {
             url = "https://mac1xa3.ca/e/zhua15/Project03/logout/",
             expect = Http.expectString GotAuth
        }

signupPost : Model -> Cmd Msg
signupPost model = 
    Http.post
        {
            url = "https://mac1xa3.ca/e/zhua15/Project03/signUp/",
            body = Http.jsonBody <| encodeCredentials model,
            expect = Http.expectString GotAuth 
        }

sendJsonPost : PlatformTuples -> Cmd Msg
sendJsonPost myPlatforms =
    Http.post
        { url = "https://mac1xa3.ca/e/zhua15/Project03/saveModel/"
        , body = Http.jsonBody <| encodeList myPlatforms
        , expect = Http.expectString GotSave
        }

getJsonPost : Model -> Cmd Msg
getJsonPost model =
    Http.post
         { url = "https://mac1xa3.ca/e/zhua15/Project03/loadModel/"
        , body = Http.jsonBody <| encodeCredentials model
        , expect = Http.expectJson GotLoad decodeList
        }
