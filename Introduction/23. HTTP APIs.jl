import HTTP
using Sockets
respond(req::HTTP.Request) = HTTP.Response(200, "hello world")
const SERVER = HTTP.Router()
HTTP.@register(SERVER, "GET", "/test", respond)
HTTP.serve(SERVER, ip"127.0.0.1", 12345)


####

# TRAITS

do_something(x::Number) = "work with a number"
do_something(x::String) = "work with a string"

# eat(::Dog) = ...
# eat(::Cat) = ...
# eat(::Sponge) = ...
# eat(::SingleCellBacteria) = ...
# eating_oriface(::Dog) = Mouth
# eating_oriface(::Cat) = Mouth
# eating_oriface(::Mammal) = Mouth
# eat(x) = eat(eating_oriface(x), x)

# eat(::Mouth, x) = .... chomp()
# eat(::CellularChannels, x) = .... absorb()

# vomiting(::Mouth, x) = ...
# vomiting(::Cel)

