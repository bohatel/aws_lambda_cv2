from token_vendor.policy_generator import PolicyGenerator

if __name__ == "__main__":
    pg = PolicyGenerator('atom')
    pg.addS3Folder('atom-root-image-store')
    print(pg.generate())
