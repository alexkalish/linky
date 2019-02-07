# Force Rails to use Oj instead of it's native decoder.
Oj.optimize_rails()

# Ensure that MultiJson uses Oj.
MultiJson.use :oj
