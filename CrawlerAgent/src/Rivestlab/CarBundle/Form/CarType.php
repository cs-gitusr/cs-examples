<?php

namespace Rivestlab\CarBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;
use Doctrine\ORM\EntityRepository;

use Rivestlab\CarBundle\Entity\Car;

class CarType extends AbstractType
{
    private function getCar(Car $tmp)
    {
        return $tmp;
    }
    
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $carEntity = $this->getCar($options['data']);
        
        $builder
            ->add('name')
            ->add('price')
            ->add('description')
            ->add('brand', 'entity', 
                    array(
                        'class' => 'RivestlabCarBundle:Brand',
                        'property' => 'name',
                        'data' => $carEntity->getModel() ? $carEntity->getModel()->getBrand() : null,
                        'property_path' => false,
                        'empty_value'=> '== Choose brand ==',
                        ))           
                
            ->add('model', 'shtumi_dependent_filtered_entity', 
                    array(
                        'entity_alias' => 'model_by_brand', 
                        'empty_value' => '== Choose model ==', 
                        'parent_field' => 'brand',
                        /*
                        'data' => $model,
                        'query_builder' => function(EntityRepository $er) use($options) {
                            return $er->createQueryBuilder('b')
                                    ->where('b.id = ?1')
                                    ->setParameter(1, $this->getModel($options['data'])->getBrand());
                        }*/
                        ))            
                /*
            ->add('brand', 'entity', 
                    array(
                        'class' => 'Rivestlab\CarBundle\Entity\Brand',
                        'property' => 'name',
                        'property_path' => false))
            ->add('model', 'entity', 
                    array(
                        'class' => 'Rivestlab\CarBundle\Entity\Model',
                        'property' => 'name',
                        'empty_value'   => '-- Select a model --',))
                 */
        ;
        
    }

    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => 'Rivestlab\CarBundle\Entity\Car'
        ));
    }

    public function getName()
    {
        return 'rivestlab_carbundle_cartype';
    }
}
