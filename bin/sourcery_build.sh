# -- model generation --

sourcery --config './Sourcery/model.sourcery.yml' 
sourcery --config './Sourcery/model.mutable.sourcery.yml' 
sourcery --config './Sourcery/wire.sourcery.yml' 

swiftformat './FableSDK/Model/Object/Generated/'
swiftformat './FableSDK/Wire/Object/Generated/'
