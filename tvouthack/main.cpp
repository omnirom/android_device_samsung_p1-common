/*
 * Copyright (C) 2011 Pawit Pornkitprasan
 * Copyright (C) 2013 OmniROM Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <binder/IPCThreadState.h>
#include <binder/ProcessState.h>
#include <binder/IServiceManager.h>
#include <utils/Log.h>

using namespace android;

int main() {
    sp<IServiceManager> sm = defaultServiceManager();
    sp<IBinder> binder;

    do {
        binder = sm->getService(String16("tvout"));
        if (binder != 0) break;
        usleep(500000); // 0.5 s
    } while(true);

    int ret;

    Parcel s2, r2;
    s2.writeInterfaceToken(String16("android.hardware.ITvOutService"));
    binder->transact(1, s2, &r2);
    sp<IBinder> binder2 = r2.readStrongBinder();

    while (true) {
        {
            Parcel send, reply;
            int code = 4;
            send.writeInterfaceToken(String16("android.hardware.ITvOut"));
            int ret = binder2->transact(code, send, &reply);
        }
        {
            Parcel send, reply;
            int code = 27;
            send.writeInterfaceToken(String16("android.hardware.ITvOut"));
            int ret = binder2->transact(code, send, &reply);
        }
        {
            Parcel send, reply;
            int code = 13;
            send.writeInterfaceToken(String16("android.hardware.ITvOut"));
            send.writeInt32(0);
            int ret = binder2->transact(code, send, &reply);
        }
        usleep(15000); // Should give ~60 fps
    }
    return 0;
}
