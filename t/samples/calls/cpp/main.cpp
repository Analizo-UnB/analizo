#include "person.h"
int sum(int a, int b){

    return a + b;

}

int plusTwo(int a){
    return sum(a,2);
}

int main(){
    Person p(12,3);
    p.getAge();
    p.old_id = 2;
    int a = 4;
    int b = 7;
    sum(a,b);
    plusTwo(b);

}
