//
//  Speech.mm
//  Speech-MacOS
//
//  Created by Zack Newman on 3/17/21.
//

//  String Utils

#import <Cocoa/Cocoa.h>

char* cStringCopy(const char* string)
{
    if (string == NULL)
        return NULL;

    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);

    return res;
}

NSString* CreateNSString(const char* string)
{
    if (string != NULL)
        return [NSString stringWithUTF8String:string];
    else
        return [NSString stringWithUTF8String:""];
}


//  RecognizerDelegate Class

#import <AppKit/AppKit.h>

@interface RecognizerDelegate : NSObject <NSSpeechRecognizerDelegate>
    @property (nonatomic) NSSpeechRecognizer* recognizer;
    @property (nonatomic) BOOL didRecognizeCommand;
    @property (nonatomic) NSString* command;
@end

@implementation RecognizerDelegate
    - (id)init
    {
        if ((self = [super init])) {
            self.didRecognizeCommand = NO;
            self.recognizer = [[NSSpeechRecognizer alloc] init];
            self.recognizer.listensInForegroundOnly = NO;
            self.recognizer.blocksOtherRecognizers = YES;
            self.recognizer.delegate = self;
        }
        return self;
    }

    - (void)startListening:(NSArray *)commands
    {
        self.recognizer.commands = commands;
        [self.recognizer startListening];
    }

    - (void)stopListening
    {
        [self.recognizer stopListening];
    }

    - (char*)getRecognizedCommand
    {
        self.didRecognizeCommand = NO;
        return cStringCopy([self.command UTF8String]);
    }

    - (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(NSString *)command
    {
        self.didRecognizeCommand = YES;
        self.command = command;
    }
@end


//  External Interface

char empty[] = "";
RecognizerDelegate *del = [[RecognizerDelegate alloc] init];

extern "C"
{
    void StartListening(char* commandsStr)
    {
        NSArray *commands = [CreateNSString(commandsStr) componentsSeparatedByString:@","];
        [del startListening:commands];
    }

    void StopListening()
    {
        [del stopListening];
    }

    bool DidRecognizeCommand()
    {
        return del.didRecognizeCommand;
    }

    char* GetRecognizedCommand()
    {
        return del.didRecognizeCommand ? [del getRecognizedCommand] : empty;
    }
}

