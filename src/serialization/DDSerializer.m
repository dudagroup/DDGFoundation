// DDSerializer.m
//
// Copyright (c) 2014 DU DA GMBH (http://www.dudagroup.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DDSerializer.h"
#import "DDSerializationMapping.h"
#import "DDMapping.h"

@implementation DDSerializer
{

}

NSString* const DDSerializerErrorDomain = @"com.dudagroup.serialization.serializer";


+ (id)objectFromDictionary:(NSDictionary*)dictionary
               withMapping:(DDSerializationMapping*)serializationMapping
                     error:(NSError**)error
{
    NSParameterAssert(serializationMapping);

    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]])
    {
        if (error)
        {
            NSString* description = [NSString stringWithFormat:@"Provided dictionary is nil or not of type NSDictionary!"];
            NSDictionary* userInfo = @
            {
                NSLocalizedDescriptionKey: description
            };

            *error = [NSError errorWithDomain:DDSerializerErrorDomain
                                         code:DDSerializerErrorCodeInvalidDictionary
                                     userInfo:userInfo];
        }

        return nil;
    }

    NSError* underlyingError = nil;
    id object = [[serializationMapping.objectClass alloc] init];

    for (id<DDMapping> mapping in serializationMapping.mappings)
    {
        [mapping mapFromDictionary:dictionary
                          toObject:object
                             error:&underlyingError];

        if (underlyingError)
        {
            if (error)
            {
                NSDictionary* userInfo = @
                {
                    NSUnderlyingErrorKey: underlyingError
                };

                *error = [NSError errorWithDomain:DDSerializerErrorDomain
                                             code:DDSerializerErrorCodeDeserializationError
                                         userInfo:userInfo];
            }

            return nil;
        }
    }

    return object;
}

@end