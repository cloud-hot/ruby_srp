require File.expand_path(File.dirname(__FILE__) + '/util')

module SRP
  module Authentication

    include Util


    def initialize_auth(aa)
      @aa = aa
      @b = bigrand(32).hex
      # B = g^b + k v (mod N)
      @bb = (modpow(GENERATOR, @b, PRIME_N) + multiplier * verifier) % PRIME_N
      u = calculate_u(@aa, @bb, PRIME_N)
      return @bb, u
    end

    def authenticate(m)
      u = calculate_u(@aa, @bb, PRIME_N)
      base = (modpow(verifier, u, PRIME_N) * @aa) % PRIME_N
      server_s = modpow(base, @b, PRIME_N)
      if(m == calculate_m(@aa, @bb, server_s))
        return calculate_m(@aa, m, server_s)
      end
    end


    protected

    def calculate_u(aa, bb, n)
      nlen = 2 * ((('%x' % [n]).length * 4 + 7) >> 3)
      aahex = '%x' % [aa]
      bbhex = '%x' % [bb]
      return sha256_str("%x%x" % [aa, bb]).hex
      hashin = '0' * (nlen - aahex.length) + aahex \
        + '0' * (nlen - bbhex.length) + bbhex
      sha256_str(hashin).hex
    end
  end

end

