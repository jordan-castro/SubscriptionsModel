from brownie import Subscription, accounts, web3
import json

# Inicia las cuentas
owner = accounts[0]
jordan = accounts[1]
boo = accounts[2]
juice = accounts[3]
trippie = accounts[4]
arthur = accounts[5]
ikki = accounts[6]
ashton = accounts[7]
tessia = accounts[8]

# Inicia el contract de subscripciones
subscriptions = Subscription.deploy({'from': owner})

# payments_contract = web3.eth.contract(abi=)

def main():
    # Escribe al archivo de JSON
    json_file = open("contract.json", "w")
    data = {
        "address": subscriptions.address,
        "abi": subscriptions.abi
    }
    json_file.write(json.dumps(data))
    json_file.close()

    # subscribe(1, "test", 0.05)
    # subscribe(0, "SUPER SECRET KEY", 0.01, sender=jordan)
    # gift(2, arthur, "Aether", 0.1, tessia)
    # change_key("My man", arthur)
    # print(is_subbed(arthur))
    # print(valid_subscriber(arthur, "My man"))


def subscribe(type, key, value, sender=None):
    print(f"Subscriptions para {account_names(sender or owner)}")
    res = subscriptions.subscribe(type, key, {'from': sender or owner, 'value': converter(value)})
    print(f"La resulta de subscribe es {res.return_value}")
    print(f"Esta subscribado? {is_subbed(sender or owner)}")
    print(f"Valido? {valid_subscriber(sender or owner, key)}")

    return res


def converter(balance, toWei=True, toEther=None):
    if toWei and not toEther:
        return web3.toWei(balance, 'ether')
    elif toEther:
        return web3.fromWei(balance, 'ether')
    else:
        return balance


def gift(type, account, key, value, sender=None): 
    print(f"Regalo para: {account_names(account)}")
    res = subscriptions.giftSubscription(type, account, key, {'from': sender or owner, 'value': converter(value)})
    print(f"La resulta de subscribe es {res.return_value}")
    print(f"Esta subscribado? {is_subbed(sender or owner)}")
    print(f"Valido? {valid_subscriber(account, key)}")


def is_subbed(account):
    res = subscriptions.subscribed(account)
    return res


def change_key(key, sender=None):
    print(f"La llave secreto es {secret_key(sender or owner)}")
    subscriptions.changeSecretKey(key, {'from': sender or owner})
    print(f"Ahora la llave es {secret_key(sender or owner)}")


def secret_key(sender):
    res = subscriptions.forgotSecretKey({'from': sender})
    return res


def valid_subscriber(account, key):
    res = subscriptions.validSubscriber(account, key)
    return res


def account_names(account, p=False):
    name = ""
    if account == owner:
        name = "Owner"
    elif account == jordan:
        name = "Jordan"
    elif account == boo:
        name = "Boo"
    elif account == juice:
        name = "Juice Wrld"
    elif account == trippie:
        name = "Trippie"
    elif account == arthur:
        name = "Arthur Leywin"
    elif account == ikki:
        name = "Ikki"
    elif account == ashton:
        name = "Ashton"
    elif account == tessia:
        name = "Tessia"
    else:
        name = "Does not exist"
    
    if p:
        print(name)

    return name


