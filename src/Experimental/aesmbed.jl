module AESmbed

description() = "This module contains a very lightweight wrapper around libmbedcrypto's aes128_ecb_encrypt"

#if libmbedcrypto is not found, then we will get a clean error on use.
#crucially, the error only appears on use, so should not affect other modules.


mutable struct Aes_wrap
    #200 bytes, opaque structure.
    data::NTuple{25, UInt64}


    @noinline function Aes_wrap(key::UInt128)
        key = htol(key)
        ctx = new()
        kr = Ref(key)
        GC.@preserve ctx kr begin
        ccall((:mbedtls_cipher_init, :libmbedcrypto), Cvoid,
            (Ptr{Cvoid},), pointer_from_objref(ctx))
        # MBEDTLS_CIPHER_ID_AES: 2, keylen:128, MBEDTLS_MODE_ECB:1
        ci = ccall((:mbedtls_cipher_info_from_values, :libmbedcrypto), Ptr{Cvoid},
        (Cint, Cint, Cint), 2, 128, 1)

        ccall((:mbedtls_cipher_setup, :libmbedcrypto), Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}), pointer_from_objref(ctx), ci)

        #keylen:128, ENCRYPT:1
        ccall((:mbedtls_cipher_setkey, :libmbedcrypto), Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}, Cint, Cint),
        pointer_from_objref(ctx), kr, 128, 1)
        end

        finalizer(ctx) do ctx_
            GC.@preserve ctx_ ccall((:mbedtls_cipher_free, :libmbedcrypto), Cvoid,
                (Ptr{Cvoid},), pointer_from_objref(ctx_))
            
            #Hygiene: zero key material before freeing it.
            #todo: check whether mbedtls already clears the key material.
            GC.@preserve ctx_ ccall(:memset, Nothing, 
                (Ptr{Nothing}, Cint, Csize_t),
                pointer_from_objref(ctx_), 0, sizeof(ctx_))
        end

        return ctx
    end
end
Base.show(io::IO, a::Aes_wrap) = print(io, "Aes_wrap($(pointer_from_objref(a)))")
(ks::Aes_wrap)(u) = enc(ks, u)



function enc(ks::Aes_wrap, v::UInt128)
    v = htol(v)
    res = Ref(UInt128(0))
    GC.@preserve ks res  ccall((:mbedtls_cipher_crypt, :libmbedcrypto), Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t, Ptr{Cvoid}, Csize_t, Ptr{Cvoid}, Ptr{Csize_t}),
        pointer_from_objref(ks), Ref(UInt128(0)), 16, Ref(v), 16,
        res, Ref{Csize_t}(16))
    return ltoh(res[])
end
end