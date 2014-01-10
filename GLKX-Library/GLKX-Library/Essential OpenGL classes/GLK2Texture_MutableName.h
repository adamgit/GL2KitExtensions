/**
 This is EXTREMELY DANGEROUS: it allows you to change the gl name of a texture; by definition,
 that's impossible - but Apple does it internally inside CoreVideo, and until Apple explains
 what they're doing and gives an official instrution, we have to play it safe and simply hack
 around their strangeness.
 
 c.f. GLK2Texture+CoreVideo.h
 */

@interface GLK2Texture()
@property(nonatomic, readwrite) GLuint glName;
@end
