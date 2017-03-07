class AbstractAnimal(object):

    def name(self):
        raise NotImplementedError()


class Mammal(AbstractAnimal):

    def close(self):
        raise NotImplementedError()


class Cat(Mammal):

    def __init__(self, name):
        self.__name = name

    def name(self):
        return self.__name

class Dog(Mammal):

    def __init__(self, name):
        self.__name = name

    def name(self):
        return self.__name

class Chain(object):

    def __init__(self):
        self.animals = []

    def add_animal(self, animal):
        self.animals.append(animal)

    def call_animals(self):
        if self.animals and len(self.animals):
            for animal in self.animals:
                print(animal.name())
        else:
            print("No animals in chain.")

    def free_animals(self):
        self.animals = []
        print("freed all animals.")

if __name__ == "__main__":
    dog = Dog("Odie")
    cat = Cat("Garfield")

    chain = Chain()
    chain.add_animal(dog)
    chain.add_animal(cat)

    chain.call_animals()
    chain.free_animals()
    chain.call_animals()

