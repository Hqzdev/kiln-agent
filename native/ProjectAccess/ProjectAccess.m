#import <Foundation/Foundation.h>
#include <jni.h>

// Ссылки удерживают доступ ровно до завершения Java backend.
static NSMutableDictionary<NSString *, NSArray *> *opened;
static NSString *javaString(JNIEnv *env, jstring value) {
    if (!value) return nil;
    const jchar *chars = (*env)->GetStringChars(env, value, NULL);
    if (!chars) return nil;
    NSString *text = [[NSString alloc] initWithCharacters:chars length:(NSUInteger)(*env)->GetStringLength(env, value)];
    (*env)->ReleaseStringChars(env, value, chars);
    return text;
}

JNIEXPORT jboolean JNICALL Java_dev_blot_infrastructure_workspace_MacProjectAccess_openBookmark(
    JNIEnv *env, jclass type, jbyteArray bytes, jstring expected) {
    @autoreleasepool {
        if (!bytes || !expected) return JNI_FALSE;
        jsize size = (*env)->GetArrayLength(env, bytes);
        if (size < 1 || size > 65536) return JNI_FALSE;
        NSMutableData *data = [NSMutableData dataWithLength:(NSUInteger)size];
        (*env)->GetByteArrayRegion(env, bytes, 0, size, data.mutableBytes);
        if ((*env)->ExceptionCheck(env)) return JNI_FALSE;
        NSString *path = javaString(env, expected);
        if (!path) return JNI_FALSE;
        NSError *error = nil;
        BOOL stale = NO;
        NSURL *url = [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithoutUI
            relativeToURL:nil bookmarkDataIsStale:&stale error:&error];
        if (!url || stale || error || ![[url.URLByResolvingSymlinksInPath path] isEqualToString:path]) return JNI_FALSE;
        BOOL started = [url startAccessingSecurityScopedResource];
        BOOL directory = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory] || !directory) {
            if (started) [url stopAccessingSecurityScopedResource];
            return JNI_FALSE;
        }
        @synchronized ([NSFileManager class]) {
            if (!opened) opened = [NSMutableDictionary dictionary];
            if (opened[path]) { if (started) [url stopAccessingSecurityScopedResource]; }
            else opened[path] = @[url, @(started)];
        }
        return JNI_TRUE;
    }
}

JNIEXPORT void JNICALL Java_dev_blot_infrastructure_workspace_MacProjectAccess_closeBookmarks(
    JNIEnv *env, jclass type) {
    @autoreleasepool {
        @synchronized ([NSFileManager class]) {
            for (NSArray *entry in opened.allValues) if ([entry[1] boolValue]) [entry[0] stopAccessingSecurityScopedResource];
            [opened removeAllObjects];
        }
    }
}
