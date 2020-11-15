import time
import serial



def UdecimalToBinary(num, intSize, fracSize):
    binary = ""

    Integral = int(num)
    fractional = num - Integral

    if (Integral == 0):
        binary = "0"
    # integral to binary
    while (Integral):
        rem = Integral % 2
        # Append 0 in binary
        binary += str(rem);
        Integral //= 2

    # Reverse string to get original binary equivalent
    binary = binary[:: -1]
    temp = ""
    if (len(binary) < intSize):
        for i in range((intSize - len(binary))):
            temp += "0"
        binary = temp + binary
    # binary += '.'

    # fration to binary
    while (fracSize):
        # Find next bit in fraction
        fractional *= 2
        fract_bit = int(fractional)

        if (fract_bit == 1):
            fractional -= fract_bit
            binary += '1'
        else:
            binary += '0'
        fracSize -= 1

    return binary


# signed converter
def SdecimalToBinary(num, intSize, fracSize):
    binary = ""
    if (num >= 0):
        return UdecimalToBinary(num, intSize, fracSize)
    else:
        temp = UdecimalToBinary(abs(num), intSize, fracSize)
        for i in range(len(temp)):
            if (temp[i] == "1"):
                binary += "0"
            elif (temp[i] == "0"):
                binary += "1"
        x = True
        i = len(temp) - 1
        while (x):
            if (binary[i] == "0"):
                if (i == len(temp) - 1):
                    Nbinary = binary[0: i]
                    Nbinary += "1"
                elif (i < len(temp) - 1):
                    Nbinary = binary[0: i]
                    Nbinary += "1"
                    Nbinary += binary[i + 1: len(temp)]
                x = False
            elif (binary[i] == "1"):
                if (i == len(temp) - 1):
                    Nbinary = binary[0: i]
                    Nbinary += "0"
                elif (i < len(temp) - 1):
                    Nbinary = binary[0: i]
                    Nbinary += "0"
                    Nbinary += binary[i + 1: len(temp)]
                i -= 1
            binary = Nbinary
        return Nbinary


def UbinaryToDecimal(num, intSize, fracSize):  #num must be string
    res = 0
    intpart = num[0:intSize]
    fracpart = num[intSize: intSize + fracSize]

    for i in range(intSize):
        if intpart[i] == "1":
            res += 2**(intSize-i-1)

    for i in range(fracSize):
        if fracpart[i] == "1":
            res += 2**(-1*(i+1))
    return res


def SbinaryToDecimal(num, intSize, fracSize):
    binary = ""

    if (num[0] == "0"):
        res = UbinaryToDecimal(num[1 : intSize + fracSize], intSize-1, fracSize)
        return(res)
    elif (num[0] == "1") :
        # temp = UdecimalToBinary(abs(num), intSize, fracSize)
        for i in range(len(num)):
            if (num[i] == "1"):
                binary += "0"
            elif (num[i] == "0"):
                binary += "1"
        x = True
        i = len(num) - 1
        while(x):
            if (binary[i] == "0"):
                if (i == len(num) - 1):
                    Nbinary = binary[0 : i]
                    Nbinary += "1"
                elif (i < len(num) - 1):
                    Nbinary = binary[0 : i]
                    Nbinary += "1"
                    Nbinary += binary[i+1 : len(num) ]
                x = False
            elif (binary[i] == "1"):
                if (i == len(num) - 1):
                    Nbinary = binary[0 : i]
                    Nbinary += "0"
                elif (i < len(num) - 1):
                    Nbinary = binary[0 : i]
                    Nbinary += "0"
                    Nbinary += binary[i+1 : len(num) ]
                i -= 1
            binary = Nbinary
        res = UbinaryToDecimal(Nbinary, intSize, fracSize)
        return(res*-1 )


def send(string, ser):
    data = string
    result = ""
    counter = int(data[0:8], base=2)
    # print("sent: " + str(counter))
    if ser.writable():
        ser.write(counter.to_bytes(1, 'big'))

    counter = int(data[8:16], base=2)
    # print("sent: " + str(counter))
    if ser.writable():
        ser.write(counter.to_bytes(1, 'big'))

    counter = int(data[16:24], base=2)
    # print("sent: " + str(counter))
    if ser.writable():
        ser.write(counter.to_bytes(1, 'big'))

    counter = int(data[24:32], base=2)
    # print("sent: " + str(counter))
    if ser.writable():
        ser.write(counter.to_bytes(1, 'big'))


def receive(ser):
    result = ""
    out = ser.read()
    while out == '':
        out = ser.read()
        # send("00000000000000000000000000000000", ser)
    result += '{0:08b}'.format(ord(out), base=2)

    out = ser.read()
    while out == '':
        out = ser.read()
    result += '{0:08b}'.format(ord(out), base=2)

    out = ser.read()
    while out == '':
        out = ser.read()
    result += '{0:08b}'.format(ord(out), base=2)

    out = ser.read()
    while out == '':
        out = ser.read()
    result += '{0:08b}'.format(ord(out), base=2)
    return result


def sendFile(num, ser, count):
    f = open(getPath(num), "r")

    while True:
        tmp = f.readline().rstrip()
        count += 1
        if tmp == '':
            break
        send(tmp, ser)
        if count%10000 == 0:
            print(str((count/380120)*100) + "%")
    return count


def getPath(s):
    return "D:/Programming/Projects/Data for CNN/Data"+s+".csv"


if __name__ == '__main__':



    # print(SdecimalToBinary(-9.9999, 8, 24))
    # print(int(SdecimalToBinary(-9.9999, 8, 24), base=2))
    # print("this" + '{0:032b}'.format(int(SdecimalToBinary(-9.9999, 8, 24), base=2)))

    # print (SdecimalToBinary(9.9999, 8, 24))
    # print (SbinaryToDecimal("11111110101000100010000110101010", 8, 24))
    # print(SbinaryToDecimal("00000001010111011101111001010110", 8, 24))

    sentencesInfo = []
    sentencesInfo.append(["the rock is destined to be the 21st century 's new conan and that he 's going to make a splash even greater than arnold schwarzenegger , jean claud van damme or steven segal", "1.366672", "-1.366672"])
    sentencesInfo.append(["the gorgeously elaborate continuation of the lord of the rings trilogy is so huge that a column of words cannot adequately describe co writer director peter jackson 's expanded vision of j r r tolkien 's middle earth", "-0.72087544", "0.72087544"])
    sentencesInfo.append(["effective but too tepid biopic", "0.27048385", "-0.27048403"])
    sentencesInfo.append(["if you sometimes like to go to the movies to have fun , wasabi is a good place to start", "-0.22252609", "0.222526"])
    sentencesInfo.append(["emerges as something rare , an issue movie that 's so honest and keenly observed that it does n't feel like one", "-0.67768335", "0.6776832"])

    ser = serial.Serial(
        port="COM5",
        baudrate=115200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        write_timeout=1
    )

    sentences = open(getPath("00"), "r")
    count = 64*300
    tc = 0
    while count > 0:
        tmp = sentences.readline().rstrip()
        if tmp == '':
            break
        send(tmp, ser)
        count -= 1
        tc+=1
        if tc % 10000 == 0:
            print(str((tc/380120)*100) + "%")

    print("hi")
    tc = sendFile("01", ser, tc)
    tc = sendFile("02", ser, tc)
    tc = sendFile("11", ser, tc)
    tc = sendFile("12", ser, tc)
    tc = sendFile("21", ser, tc)
    tc = sendFile("22", ser, tc)
    tc = sendFile("0", ser, tc)
    tc = sendFile("1", ser, tc)

    send("01111111111111111111111111111111", ser)

    pointer = 0
    while(1):
        data = receive(ser)
        print("Sentence: " + str(sentencesInfo[pointer][0]))
        print("class #1 value: " + str(SbinaryToDecimal(data, 8, 24)))
        print("expected value: " + str(sentencesInfo[pointer][1]))
        data = receive(ser)
        print("class #2 value: " + str(SbinaryToDecimal(data, 8, 24)))
        print("expected value: " + str(sentencesInfo[pointer][2]))
        pointer+=1
        input()

        # send next sentence
        count = 300 * 64
        while count > 0:
            tmp = sentences.readline().rstrip()
            if tmp == '':
                break
            send(tmp, ser)
            count -= 1

        send("01111111111111111111111111111111", ser)

