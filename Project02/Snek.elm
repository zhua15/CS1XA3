--Very Creative Snek
import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import Random exposing (..)
import List exposing (..)

type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | RandColour Color
         | RandApple (Float,Float)

type alias Model = 
    { size : Int
    , youdied : Bool
    , colour : Color
    , posx : Float
    , posy : Float
    , xmove : Float
    , ymove : Float
    , randColour : Float
    , apple : (Float,Float)
    , appleC : Color
    , bgC : Color
    , posxtrack : List Float
    , posytrack : List Float
    }

snekspeed = 0.8 -- slower speed = smaller snek
applehit = 2 -- apple size and hitbox

init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =  ({ size = 0, youdied = False, colour = black, posx = 0, posy = 0, xmove = 0, ymove = 0, randColour = 0, apple = (35,35), appleC = red, bgC = black, posxtrack = (repeat 5 (0)), posytrack = (repeat 5 (0))}, Random.generate RandApple (pair (float -35 35) (float -35 35)))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        Tick time (keyToState,(arrowX,arrowY),(wasdX,wasdY)) -> -- if dead then nothing left
            if model.youdied == True then 
                case keyToState (Space) of
                    JustDown -> ({ size = 0, youdied = False, colour = black, posx = 0, posy = 0, xmove = 0, ymove = 0, randColour = 0, apple = (35,35), appleC = red, bgC = black, posxtrack = [0,0,0], posytrack = [0,0,0]}, generateNewApple model)
                    _        -> ({ model | xmove = 0, ymove = 0, colour = blank, appleC = blank, bgC = blank}, Cmd.none)

            else if wallCollide model || (selfCollide model && model.size > 3) then -- if collides then die
                ({ model | youdied = True, colour = blank}, Cmd.none)
             
            else if wasdX == 0 && wasdY /= 0 && wasdY /= (-1)*model.ymove then -- case for up/down movement
                snekMove model (keyToState,(arrowX,arrowY),(wasdX,wasdY))

            else if wasdX /= 0 && wasdY == 0 && wasdX /= (-1)*model.xmove then -- case for left/right movement
                snekMove model (keyToState,(arrowX,arrowY),(wasdX,wasdY))
                
            else -- no movement
                let
                    rand = case keyToState (Key "r") of
                        JustDown -> 
                            if model.randColour == 255 then 1 else 255 
                        _ -> model.randColour
                    myposx = model.posx + model.xmove * snekspeed
                    myposy = model.posy + model.ymove * snekspeed
                    (ax,ay) = model.apple
                in 
                    if abs(ax - myposx) < 2*snekspeed && abs(ay - myposy) < 2*snekspeed then
                        ({model | posx = myposx,  posy = myposy, size = model.size + 1, posxtrack = myposx :: model.posxtrack, posytrack = myposy :: model.posytrack}, generateNewApple model)
                    else
                        ({model | posx = myposx,  posy = myposy, randColour = rand, posxtrack = myposx :: model.posxtrack, posytrack = myposy :: model.posytrack}, generateNewColour model)
        RandApple (a,b) ->
            ( {model | apple = (a,b)}, Cmd.none)
        RandColour a-> 
            ( {model | colour = a}, Cmd.none)
        MakeRequest req -> (model, Cmd.none)
        UrlChange url -> (model, Cmd.none)

generateNewColour : Model -> Cmd Msg
generateNewColour model = Random.generate RandColour (Random.map3 rgb (float 1 model.randColour) (float 1 model.randColour) (float 1 model.randColour))

generateNewApple : Model -> Cmd Msg
generateNewApple model = Random.generate RandApple (pair (float -35 35) (float -35 35))

snekMove : Model -> GetKeyState -> (Model, Cmd Msg)
snekMove model (keyToState,(arrowX,arrowY),(wasdX,wasdY)) = 
    let
        rand = case keyToState (Key "r") of
            JustDown -> 
                if model.randColour == 255 then 1 else 255 
            _ -> model.randColour
        myposx = model.posx + model.xmove * snekspeed
        myposy = model.posy + model.ymove * snekspeed
        (ax,ay) = model.apple
    in
    if abs(ax - myposx) < applehit*snekspeed && abs(ay - myposy) < applehit*snekspeed then
        ({model | posx = myposx,  posy = myposy, size = model.size + 1, posxtrack = myposx :: model.posxtrack, posytrack = myposy :: model.posytrack}, generateNewApple model)
    else    
        ({model | posx = myposx,  posy = myposy, xmove = wasdX, ymove = wasdY, randColour = rand, posxtrack = myposx :: model.posxtrack, posytrack = myposy :: model.posytrack}, generateNewColour model)


wallCollide : Model -> Bool
wallCollide model = 
    if abs model.posx > (35+2-snekspeed) || abs model.posy > (35+2-snekspeed) then
        True
    else
        False

selfCollide : Model -> Bool
selfCollide model =
    if model.size /=0 then
        let
            x = case head (drop 5 model.posxtrack) of
                    Just first -> first
                    _ -> 300
            y = case head (drop 5 model.posytrack) of
                    Just first -> first
                    _ -> 300
            xs = case tail model.posxtrack of
                    Just first -> first
                    _ -> []
            ys = case tail model.posytrack of
                    Just first -> first
                    _ -> []
        in 
        if abs (model.posx - x) < 2*snekspeed && abs (model.posy - y) < 2*snekspeed then
            True
        else 
            selfCollide {model | size = model.size-1, posxtrack = drop 2 xs, posytrack = drop 2 ys}
    else
        False
    
view : Model -> { title : String, body : Collage Msg }
view model = 
    let
        title = "Snek"
        body = collage 100 100 snekgroup
        snekgroup = [snekhead, bg, snektext, youLostText] ++ snekbody ++ [delicious]
        snekhead = square (2*snekspeed) |> outlined (solid (1*snekspeed)) model.colour |> move (model.posx, model.posy)
        snekbody = snekExtend model
        bg = square 75 |> outlined (solid 1) model.bgC
        snektext = GraphicSVG.text ("Score: "++ (String.fromInt model.size )) |> bold |> GraphicSVG.size 5 |> filled purple |> move (-8, 40)
        youLostText = ifLose model
        delicious = square (applehit*snekspeed) |> filled model.appleC |> move model.apple
    in { title = title , body = body }

ifLose : Model -> Shape userMsg
ifLose model = 
    if model.youdied == True then
        GraphicSVG.text ("You Lose") |> bold |> GraphicSVG.size 8 |> filled black |> move (-15,0)
    else
        GraphicSVG.text ("Press R for Special Effects!") |> bold |> GraphicSVG.size 5 |> filled purple |> move (-30,-45)

snekExtend : Model -> List (Shape userMsg)
snekExtend model =  
    if model.size /=0 then
        let
            x = case head (drop 2 model.posxtrack) of
                    Just first -> first
                    _ -> 0
            y = case head (drop 2 model.posytrack) of
                    Just first -> first
                    _ -> 0
            xs = case tail model.posxtrack of
                    Just first -> first
                    _ -> []
            ys = case tail model.posytrack of
                    Just first -> first
                    _ -> []

        in [square (3*snekspeed) |> filled model.colour |> move (x,y) ] ++ snekExtend { model | size = model.size-1, posxtrack = drop 2 xs, posytrack = drop 2 ys}
    else
        []
    
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