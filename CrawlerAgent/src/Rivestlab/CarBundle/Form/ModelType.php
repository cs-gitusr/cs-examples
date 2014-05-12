<?php

namespace Rivestlab\CarBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;

class ModelType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            ->add('name')
            ->add('brand', 'entity', array('class' => 'Rivestlab\CarBundle\Entity\Brand', 'property' => 'name'))
        ;
    }

    public function setDefaultOptions(OptionsResolverInterface $resolver)
    {
        $resolver->setDefaults(array(
            'data_class' => 'Rivestlab\CarBundle\Entity\Model'
        ));
    }

    public function getName()
    {
        return 'rivestlab_carbundle_modeltype';
    }
}
