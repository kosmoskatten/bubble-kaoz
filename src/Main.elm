module Main exposing (main)

import AnimationFrame exposing (diffs)
import BubbleMaker exposing (BubbleMaker)
import Html exposing (Html)
import Html.Attributes as Attr
import Math.Matrix4 exposing (Mat4, makePerspective, makeLookAt)
import Math.Vector3 exposing (Vec3, vec3)
import Random as Random
import Time exposing (Time, millisecond, every)
import WebGL as GL


type alias Model =
    { proj :
        Mat4
        -- The projection matrix.
    , view :
        Mat4
        -- The camera matrix.
    , bubbleMaker :
        BubbleMaker
        -- The bubble maker.
    }


type Msg
    = Tick
    | NewBubbleVector Vec3
    | Animate Time


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { proj =
            makePerspective 45 (toFloat width / toFloat height) 0.01 100
      , view = makeLookAt (vec3 0 0 50) (vec3 0 0 0) (vec3 0 1 0)
      , bubbleMaker = BubbleMaker.init
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    GL.toHtmlWith
        [ GL.depth 1
        , GL.antialias
        , GL.alpha True
        , GL.clearColor 0 0 (102 / 255) 1
        ]
        [ Attr.width width
        , Attr.height height
        ]
    <|
        BubbleMaker.render model.proj model.view model.bubbleMaker


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick ->
            ( model, Random.generate NewBubbleVector BubbleMaker.randomVec3 )

        NewBubbleVector vec ->
            ( { model
                | bubbleMaker =
                    BubbleMaker.newBubble vec model.bubbleMaker
              }
            , Cmd.none
            )

        Animate t ->
            ( { model
                | bubbleMaker =
                    BubbleMaker.animate t model.bubbleMaker
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ every (500 * millisecond) (always Tick), diffs Animate ]


width : Int
width =
    1024


height : Int
height =
    768
