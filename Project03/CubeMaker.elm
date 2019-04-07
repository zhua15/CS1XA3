import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import Random exposing (..)
import List exposing (..)
import Http

g = 0.1
a = 0.06
friction = 0.03
jumpStrength = 2 -- be reasonable, jump heights of over 75 will break collision detection
initialPlatforms = [((-20,-4),(-38,-36),black),((-4,30),(-39,-38),blue),((-10,10),(-16,-14),purple),((20,30),(6,8),orange),((-10,0),(20,22),green)]
numplayers = 2 -- will increase player limit beyond 2 soon
playerColours = ((purple,blue),(red,green))
cubesize = 3
startposx = ((-25,-10),(10,25))
startposy = ((-38,-38),(-38,-38))

type Msg = Tick Float GetKeyState
         | SaveTap
         | LoadTap
         | NewTap
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | GotText (Result Http.Error String)

type alias Model = 
    {
        player1 : (Bool,Color),
        player2 : (Bool,Color),
        player3 : (Bool,Color),
        player4 : (Bool,Color),
        velx : FourTuples,
        vely : FourTuples,
        posx : FourTuples,
        posy : FourTuples,
        response : String,
        platform : PlatformTuples
    }

type alias PlatformTuples = List((Float,Float),(Float,Float),Color)
type alias FourTuples = ((Float,Float),(Float,Float))

init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =    let
                            ((c1,c2),(c3,c4)) = playerColours
                        in
                        ({
                        player1 = if numplayers >= 1 then (True,c1) else (False,blank),
                        player2 = if numplayers >= 2 then (True,c2) else (False,blank),
                        player3 = if numplayers >=3 then (True,c3) else (False,blank),
                        player4 = if numplayers >=4 then (True,c4) else (False,blank),
                        velx  = ((0,0),(0,0)),
                        vely = ((0,0),(0,0)),
                        posx = startposx,
                        posy = startposy,
                        response = "",
                        platform = initialPlatforms
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
                velx3new = velxUpdate model.posx model.posy model.velx model.vely 0 isAlive3 3 model.platform -- Will implement multiplayer
                posx3new = posxUpdate model.posx model.posy model.velx model.vely isAlive3 3 model.platform
                vely3new = velyUpdate model.posx model.posy model.velx model.vely 0 isAlive3 3 model.platform
                posy3new = posyUpdate model.posx model.posy model.velx model.vely isAlive3 3 model.platform
                velx4new = velxUpdate model.posx model.posy model.velx model.vely 0 isAlive4 4 model.platform
                posx4new = posxUpdate model.posx model.posy model.velx model.vely isAlive4 4 model.platform
                vely4new = velyUpdate model.posx model.posy model.velx model.vely 0 isAlive4 4 model.platform
                posy4new = posyUpdate model.posx model.posy model.velx model.vely isAlive4 4 model.platform
            in ({model | posx = ((posx1new,posx2new),(posx3new,posx4new)), velx = ((velx1new,velx2new),(velx3new,velx4new)), posy = ((posy1new,posy2new),(posy3new,posy4new)), vely = ((vely1new,vely2new),(vely3new,vely4new))}, Cmd.none)

        SaveTap -> ({ model | posy = ((0,0),(0,0)), posx = ((0,0),(0,0)) }, Cmd.none)
        LoadTap -> (model, Cmd.none)
        NewTap -> ({ model | platform = [] }, Cmd.none)

        MakeRequest req -> (model, Cmd.none)
        UrlChange url -> (model, Cmd.none)

        GotText result ->
            case result of
                Ok val ->
                    ({model | response = val}, Cmd.none)
                    
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

serverSave : String -> String -> String -> Cmd Msg
serverSave myUser myPass myAgain =
    Http.post
        { url = "https://mac1xa3.ca/e/zhua15/lab7/"
        , body = Http.stringBody "application/x-www-form-urlencoded" ("user="++myUser++"&password="++myPass++"&passwordagain="++myAgain)
        , expect = Http.expectString GotText
        }

serverLoad : String -> String -> String -> Cmd Msg
serverLoad myUser myPass myAgain =
    Http.post
        { url = "https://mac1xa3.ca/e/zhua15/lab7/"
        , body = Http.stringBody "application/x-www-form-urlencoded" ("user="++myUser++"&password="++myPass++"&passwordagain="++myAgain)
        , expect = Http.expectString GotText
        }

view : Model -> { title : String, body : Collage Msg }
view model = 
    let
        title = "CubeStomp"
        body = collage 100 100 gameall

        gameall = playergroup ++ playerModelGroup ++ platforms ++ bg ++ buttons
        bg = [square 80 |> outlined (solid 1) black]

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

        platforms = (platformGenerate model.platform)

        buttons = [group[save,load,new,saveText,loadText,newText]]   
        saveText = text "Save" |> size 3 |> filled black |> move (-48, 7) |> notifyTap SaveTap
        loadText = text "Load" |> size 3 |> filled black |> move (-48, -1) |> notifyTap LoadTap
        newText = text "New" |> size 3 |> filled black |> move (-48, -9) |> notifyTap NewTap
        save =  square 7 |> filled grey |> move (-45,8) |> notifyTap SaveTap
        load = square 7 |> filled grey |> move (-45,0) |> notifyTap LoadTap
        new = square 7 |> filled grey |> move (-45,-8) |> notifyTap NewTap

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
        icon = group [square 8 |> filled playercolour, iconame] |> move (x,y)
        iconame = text (String.fromInt playernum) |> size 3 |> filled white |> move (-0.5,-0.7)
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
        [square cubesize |> filled playercolour |> move (posx,posy)]
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
    else if posx+velx < -(39.5 - (cubesize/2)) then
        -(39.5 - (cubesize/2))
    else if posx+velx > (39.5 - (cubesize/2)) then
        (39.5 - (cubesize/2))
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
    else if posy+vely < -(39.5 - (cubesize/2)) then
        -(39.5 - (cubesize/2))
    else if posy+vely > (39.5 - (cubesize/2)) then
        (39.5 - (cubesize/2))
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
            posy + vely

helperVelx : Float -> Float -> Float -> PlatformTuples -> Bool   
helperVelx posx posy velx x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
            False
        else
            helperVelx posx posy velx x2 || posy > ymin - cubesize/2 && posy < ymax + cubesize/2 && (posx == xmin - (cubesize/2) || posx == xmax + (cubesize/2))

helperVelyT : Float -> Float -> Float -> PlatformTuples -> Bool
helperVelyT posx posy vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
            False
        else
            (helperVelyT posx posy vely x2) || (posy == ymax + cubesize/2 && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) && vely < 0)

helperVelyB : Float -> Float -> Float ->PlatformTuples -> Bool
helperVelyB posx posy vely x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
            False
        else
            (helperVelyB posx posy vely x2) || (posy == ymin - cubesize/2 && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) && vely > 0)

helperPosxL : Float -> Float -> Float -> PlatformTuples -> (Bool,Float)
helperPosxL posx posy velx x = 
    let
        header = case head(x) of
                            Just v -> v
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
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
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
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
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
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
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
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
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
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
                            Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
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
                    Nothing -> ((0,0),(0,0),blank)
        ((xmin,xmax),(ymin,ymax),colour) = header
        x2 = case tail(x) of
                Just v -> v
                Nothing -> []
    in  if x2 == [] && header == ((0,0),(0,0),blank) then
            False
        else if posy == ymax + cubesize/2 && posx > xmin - (cubesize/2) && posx < xmax + (cubesize/2) then
            True
        else
            isPlatform posx posy x2

platformGenerate : PlatformTuples -> List (Shape userMsg)
platformGenerate platformList = 
    let
        header =  case head(platformList) of
                    Just v -> v
                    Nothing -> ((0,0),(0,0),blank)

        ((xmin,xmax),(ymin,ymax),colour) = header
        
        x2 = case tail(platformList) of
                Just v -> v
                Nothing -> []
    in 
    if x2 /= [] then
        [rectangle (abs(xmax - xmin)) (abs(ymax - ymin)) |> filled colour |> move (((xmin + xmax)/2),((ymax + ymin)/2))] ++ platformGenerate x2
    else
        [rectangle (abs(xmax - xmin)) (abs(ymax - ymin)) |> filled colour |> move (((xmin + xmax)/2),((ymax + ymin)/2))]