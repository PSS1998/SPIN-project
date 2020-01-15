chan order=[0] of {byte};
chan orderPrice=[0] of {byte};
chan orderPricePerson=[0] of {byte};
chan paymentSuccess=[0] of {byte};
chan paymentSuccessPerson=[0] of {byte};
chan payment=[0] of {byte};
chan saleItem=[0] of {byte};

int boughtItem = 0;
int orderNum = 0;
int result = 0;

proctype person(){
int price;
int success = 0;
L1:do
:: orderNum = 1 -> break 
:: orderNum = 2 -> break
od
order!orderNum;
orderPricePerson?price;
L5:do
:: payment!price -> break
:: paymentSuccess!0 -> break 
:: payment!0 -> goto L1
od
paymentSuccessPerson?success;
do
:: (success == 1) -> saleItem?boughtItem -> break
:: (success == 0) -> goto L5
od
}

proctype cardReader(){
int price;
int paymentPrice;
/*bit result = 0;*/
L2:orderPrice?price;
orderPricePerson!price;
L3:payment?paymentPrice;
do
:: (paymentPrice == price) -> paymentSuccess!1 -> paymentSuccessPerson!1 -> break
:: paymentSuccessPerson!0 -> goto L3
:: (paymentPrice == 0) -> goto L2
od
}

proctype vendingMachine(){
byte orderNumber = 0;
/*bit result = 0;*/
int priceList[2];
byte list[2];
list[0] = 10;
list[1] = 3;
priceList[0] = 2;
priceList[1] = 3;
L3:order?orderNumber;
if
:: (list[orderNumber-1] > 0) -> orderPrice!priceList[orderNumber-1]
:: (list[orderNumber-1] == 0) -> orderPrice!0 -> goto L3
fi
paymentSuccess?result;
do
:: (result == 1) /*-> list[orderNumber-1]--*/ -> saleItem!orderNumber -> break
/*:: (result == 1) -> list[orderNumber-1]-- -> break*/
:: (result != 1) -> goto L3
od
}


init{ 
  atomic{ 
    run vendingMachine(); 
    run cardReader(); 
    run person();
  } 
}

ltl p1 { ((orderNum == 0) && (boughtItem == 0)) U (always eventually (orderNum == boughtItem)) }
