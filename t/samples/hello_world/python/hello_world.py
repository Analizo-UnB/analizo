class HelloWorld(object):
  _id_seq = 0

  def __init__(self):
    self.hello = 1
    self._id_seq += 1
    self._id = self._id_seq

  def say(self):
    print("Hello, world! My is id {}".format(self._id))

  def destroy(self):
    print("Goodbye, world! My id is {}".format(self._id))

  def __private_method(self):
    self.hello = 2
    print(hello)


if __name__ == "__main__":
  hello1 = HelloWorld()
  hello2 = HelloWorld()

  hello1.say()
  hello2.say()

  # Yes, I know Java does not need destructors, but I want the program to
  # work just like the C and C++ ones, and I cannot guarantee when (or if)
  # finalize() will be called.
  hello1.destroy()
  hello2.destroy()
