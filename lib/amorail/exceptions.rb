# Classes for Amorail Exceptions
# Every class is name of HTTP response error code(status)

class AmoBadRequestError < StandardError; end

class AmoMovedPermanentlyError < StandardError; end

class AmoUnauthorizedError < StandardError; end

class AmoForbiddenError < StandardError; end

class AmoNotFoudError < StandardError; end

class AmoInternalError < StandardError; end

class AmoBadGatewayError < StandardError; end

class AmoServiceUnaviableError < StandardError; end
